#include "ClimateModel.h"

#include <QRandomGenerator>
#include <QVariantList>

ClimateModel::ClimateModel(QObject *parent)
    : QAbstractListModel(parent)
{
    struct Seed { const char *name; double temperature; double humidity; };
    const Seed seeds[] = {
        { "Living Room", 22.4, 44 },
        { "Bedroom",     20.8, 51 },
        { "Kitchen",     24.1, 38 },
        { "Office",      21.6, 47 },
        { "Bathroom",    23.2, 62 },
        { "Greenhouse",  26.7, 70 },
    };

    auto *rng = QRandomGenerator::global();
    for (const Seed &seed : seeds) {
        Room room;
        room.name = QString::fromUtf8(seed.name);
        room.temperature = seed.temperature;
        room.humidity = seed.humidity;
        // Prime history with a gentle random walk so charts look alive at start.
        double temperature = seed.temperature, humidity = seed.humidity;
        for (int i = 0; i < kHistory; ++i) {
            temperature += (rng->bounded(21) - 10) / 40.0;
            humidity     += (rng->bounded(21) - 10) / 18.0;
            temperature = qBound(15.0, temperature, 30.0);
            humidity = qBound(25.0, humidity, 85.0);
            room.temperatureHistory.append(temperature);
            room.humidityHistory.append(humidity);
        }
        room.temperature = room.temperatureHistory.last();
        room.humidity = room.humidityHistory.last();
        m_items.append(room);
    }

    m_timer.setInterval(2000);
    connect(&m_timer, &QTimer::timeout, this, &ClimateModel::tick);
    m_timer.start();
}

int ClimateModel::rowCount(const QModelIndex &parent) const
{
    if (parent.isValid())
        return 0;
    return m_items.size();
}

QVariant ClimateModel::data(const QModelIndex &index, int role) const
{
    if (!index.isValid() || index.row() < 0 || index.row() >= m_items.size())
        return {};

    const Room &room = m_items.at(index.row());
    switch (role) {
    case NameRole:        return room.name;
    case TemperatureRole: return QString::number(room.temperature, 'f', 1);
    case HumidityRole:    return qRound(room.humidity);
    case TrendRole:       return room.trend;
    case TempMinRole: {
        double minimum = room.temperatureHistory.isEmpty() ? room.temperature : room.temperatureHistory.first();
        for (double v : room.temperatureHistory) minimum = qMin(minimum, v);
        return QString::number(minimum, 'f', 1);
    }
    case TempMaxRole: {
        double max = room.temperatureHistory.isEmpty() ? room.temperature : room.temperatureHistory.first();
        for (double v : room.temperatureHistory) max = qMax(max, v);
        return QString::number(max, 'f', 1);
    }
    case TempHistoryRole: {
        QVariantList list;
        list.reserve(room.temperatureHistory.size());
        for (double v : room.temperatureHistory) list.append(v);
        return list;
    }
    case HumHistoryRole: {
        QVariantList list;
        list.reserve(room.humidityHistory.size());
        for (double v : room.humidityHistory) list.append(v);
        return list;
    }
    }
    return {};
}

QHash<int, QByteArray> ClimateModel::roleNames() const
{
    return {
        { NameRole,        "name" },
        { TemperatureRole, "temperature" },
        { HumidityRole,    "humidity" },
        { TempHistoryRole, "tempHistory" },
        { HumHistoryRole,  "humHistory" },
        { TempMinRole,     "tempMin" },
        { TempMaxRole,     "tempMax" },
        { TrendRole,       "trend" },
    };
}

QString ClimateModel::avgTemperature() const
{
    if (m_items.isEmpty())
        return QStringLiteral("0.0");
    double sum = 0;
    for (const Room &room : m_items)
        sum += room.temperature;
    return QString::number(sum / m_items.size(), 'f', 1);
}

int ClimateModel::avgHumidity() const
{
    if (m_items.isEmpty())
        return 0;
    double sum = 0;
    for (const Room &room : m_items)
        sum += room.humidity;
    return qRound(sum / m_items.size());
}

void ClimateModel::tick()
{
    auto *rng = QRandomGenerator::global();
    for (int i = 0; i < m_items.size(); ++i) {
        Room &room = m_items[i];

        double prev = room.temperature;
        room.temperature += (rng->bounded(21) - 10) / 30.0;
        room.humidity  += (rng->bounded(21) - 10) / 14.0;
        room.temperature = qBound(15.0, room.temperature, 30.0);
        room.humidity  = qBound(25.0, room.humidity, 85.0);

        double d = room.temperature - prev;
        room.trend = (d > 0.05) ? 1 : (d < -0.05 ? -1 : 0);

        room.temperatureHistory.append(room.temperature);
        room.humidityHistory.append(room.humidity);
        if (room.temperatureHistory.size() > kHistory) room.temperatureHistory.removeFirst();
        if (room.humidityHistory.size() > kHistory)  room.humidityHistory.removeFirst();

        emit dataChanged(index(i), index(i),
                         { TemperatureRole, HumidityRole, TempHistoryRole,
                           HumHistoryRole, TempMinRole, TempMaxRole, TrendRole });
    }
    emit summaryChanged();
}


void ClimateModel::addZone(const QString &name)
{
    Room climate_zone;
    climate_zone.name = name.trimmed().isEmpty() ? QStringLiteral("New Zone") : name.trimmed();
    climate_zone.humidity = 10;
    climate_zone.humidityHistory.append(10);
    climate_zone.temperature = 10;
    climate_zone.temperatureHistory.append(10);
    climate_zone.trend = 10;

    const int row = m_items.size();
    beginInsertRows(QModelIndex(), row, row);
    m_items.append(climate_zone);
    endInsertRows();
    emit summaryChanged();
}

void ClimateModel::removeZone(int row)
{
    if (row < 0 || row >= m_items.size())
        return;
    beginRemoveRows(QModelIndex(), row, row);
    m_items.removeAt(row);
    endRemoveRows();
    emit summaryChanged();
}