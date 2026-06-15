#include "WateringZoneModel.h"

#include <QRandomGenerator>

WateringZoneModel::WateringZoneModel(QObject *parent)
    : QAbstractListModel(parent)
{
    m_items = {
        { QStringLiteral("Front Lawn"),   62.0, false, true,  12, 0, 0.0, 40.0 },
        { QStringLiteral("Vegetable Bed"),38.0, false, true,  8,  0, 0.0, 45.0 },
        { QStringLiteral("Greenhouse"),   71.0, false, true,  6,  0, 0.0, 55.0 },
        { QStringLiteral("Flower Beds"),  29.0, false, true,  10, 0, 0.0, 35.0 },
        { QStringLiteral("Back Garden"),  54.0, false, false, 15, 0, 0.0, 40.0 },
    };

    // 1 Hz simulation tick.
    m_timer.setInterval(1000);
    connect(&m_timer, &QTimer::timeout, this, &WateringZoneModel::tick);
    m_timer.start();
}

int WateringZoneModel::rowCount(const QModelIndex &parent) const
{
    if (parent.isValid())
        return 0;
    return m_items.size();
}

QVariant WateringZoneModel::data(const QModelIndex &index, int role) const
{
    if (!index.isValid() || index.row() < 0 || index.row() >= m_items.size())
        return {};

    const Zone &zone = m_items.at(index.row());
    switch (role) {
    case NameRole:      return zone.name;
    case MoistureRole:  return qRound(zone.moisture);
    case WateringRole:  return zone.watering;
    case AutoRole:      return zone.autoMode;
    case DurationRole:  return zone.duration;
    case RemainingRole: return zone.remaining;
    case FlowRole:      return QString::number(zone.flow, 'f', 1);
    }
    return {};
}

QHash<int, QByteArray> WateringZoneModel::roleNames() const
{
    return {
        { NameRole,      "name" },
        { MoistureRole,  "moisture" },
        { WateringRole,  "watering" },
        { AutoRole,      "autoMode" },
        { DurationRole,  "duration" },
        { RemainingRole, "remaining" },
        { FlowRole,      "flow" },
    };
}

int WateringZoneModel::activeCount() const
{
    int n = 0;
    for (const Zone &zone : m_items)
        if (zone.watering)
            ++n;
    return n;
}

int WateringZoneModel::averageMoisture() const
{
    if (m_items.isEmpty())
        return 0;
    double sum = 0;
    for (const Zone &zone : m_items)
        sum += zone.moisture;
    return qRound(sum / m_items.size());
}

void WateringZoneModel::start(int row)
{
    if (row < 0 || row >= m_items.size())
        return;
    Zone &zone = m_items[row];
    if (zone.watering)
        return;
    zone.watering = true;
    zone.remaining = zone.duration * 60;
    zone.flow = 4.0 + QRandomGenerator::global()->bounded(20) / 10.0; // 4.0..6.0
    emit dataChanged(index(row), index(row),
                     { WateringRole, RemainingRole, FlowRole });
    emit summaryChanged();
}

void WateringZoneModel::stop(int row)
{
    if (row < 0 || row >= m_items.size())
        return;
    Zone &zone = m_items[row];
    if (!zone.watering)
        return;
    zone.watering = false;
    zone.remaining = 0;
    zone.flow = 0.0;
    emit dataChanged(index(row), index(row),
                     { WateringRole, RemainingRole, FlowRole });
    emit summaryChanged();
}

void WateringZoneModel::setAuto(int row, bool enable)
{
    if (row < 0 || row >= m_items.size())
        return;
    if (m_items[row].autoMode == enable)
        return;
    m_items[row].autoMode = enable;
    emit dataChanged(index(row), index(row), { AutoRole });
}

void WateringZoneModel::setDuration(int row, int minutes)
{
    if (row < 0 || row >= m_items.size())
        return;
    minutes = qBound(1, minutes, 60);
    if (m_items[row].duration == minutes)
        return;
    m_items[row].duration = minutes;
    emit dataChanged(index(row), index(row), { DurationRole });
}

void WateringZoneModel::stopAll()
{
    for (int i = 0; i < m_items.size(); ++i)
        stop(i);
}

void WateringZoneModel::addZone(const QString &name)
{
    Zone zone;
    zone.name = name.trimmed().isEmpty() ? QStringLiteral("New Zone") : name.trimmed();
    zone.moisture = 50.0;
    zone.autoMode = true;
    zone.duration = 10;
    zone.threshold = 40.0;

    const int row = m_items.size();
    beginInsertRows(QModelIndex(), row, row);
    m_items.append(zone);
    endInsertRows();
    emit summaryChanged();
}

void WateringZoneModel::removeZone(int row)
{
    if (row < 0 || row >= m_items.size())
        return;
    beginRemoveRows(QModelIndex(), row, row);
    m_items.removeAt(row);
    endRemoveRows();
    emit summaryChanged();
}

void WateringZoneModel::tick()
{
    auto *rng = QRandomGenerator::global();
    for (int i = 0; i < m_items.size(); ++i) {
        Zone &zone = m_items[i];
        QVector<int> roles;

        if (zone.watering) {
            // Run down the timer; moisture climbs while watering.
            zone.remaining -= 1;
            zone.moisture = qMin(100.0, zone.moisture + 0.6);
            zone.flow = qMax(0.0, zone.flow + (rng->bounded(11) - 5) / 50.0);
            roles << RemainingRole << MoistureRole << FlowRole;
            if (zone.remaining <= 0) {
                zone.watering = false;
                zone.remaining = 0;
                zone.flow = 0.0;
                roles << WateringRole;
                emit summaryChanged();
            }
        } else {
            // Slow drying between waterings.
            double dry = (rng->bounded(8)) / 100.0; // 0..0.07 per sec
            if (zone.moisture > 0.0) {
                zone.moisture = qMax(0.0, zone.moisture - dry);
                roles << MoistureRole;
            }
            // Auto irrigation kicks in below threshold.
            if (zone.autoMode && zone.moisture < zone.threshold) {
                zone.watering = true;
                zone.remaining = zone.duration * 60;
                zone.flow = 4.0 + rng->bounded(20) / 10.0;
                roles << WateringRole << RemainingRole << FlowRole;
                emit summaryChanged();
            }
        }

        if (!roles.isEmpty())
            emit dataChanged(index(i), index(i), roles);
    }
    emit summaryChanged();
}
