#include "RoomLightModel.h"

RoomLightModel::RoomLightModel(QObject *parent)
    : QAbstractListModel(parent)
{
    m_items = {
        { QStringLiteral("Living Room"), QStringLiteral("home"),    true,  82, 25 },
        { QStringLiteral("Kitchen"),     QStringLiteral("bulb"),    true,  95, 55 },
        { QStringLiteral("Bedroom"),     QStringLiteral("bulb"),    false, 40, 12 },
        { QStringLiteral("Bathroom"),    QStringLiteral("bulb"),    false, 60, 70 },
        { QStringLiteral("Office"),      QStringLiteral("bulb"),    true,  75, 80 },
        { QStringLiteral("Hallway"),     QStringLiteral("bulb"),    false, 30, 40 },
    };
}

int RoomLightModel::rowCount(const QModelIndex &parent) const
{
    if (parent.isValid())
        return 0;
    return m_items.size();
}

QVariant RoomLightModel::data(const QModelIndex &index, int role) const
{
    if (!index.isValid() || index.row() < 0 || index.row() >= m_items.size())
        return {};

    const Light &light_zone = m_items.at(index.row());
    switch (role) {
    case NameRole:       return light_zone.name;
    case IconRole:       return light_zone.icon;
    case OnRole:         return light_zone.on;
    case BrightnessRole: return light_zone.brightness;
    case WarmthRole:     return light_zone.warmth;
    }
    return {};
}

QHash<int, QByteArray> RoomLightModel::roleNames() const
{
    return {
        { NameRole,       "name" },
        { IconRole,       "icon" },
        { OnRole,         "on" },
        { BrightnessRole, "brightness" },
        { WarmthRole,     "warmth" },
    };
}

int RoomLightModel::onCount() const
{
    int n = 0;
    for (const Light &light_zone : m_items)
        if (light_zone.on)
            ++n;
    return n;
}

int RoomLightModel::averageBrightness() const
{
    int sum = 0, n = 0;
    for (const Light &light_zone : m_items) {
        if (light_zone.on) {
            sum += light_zone.brightness;
            ++n;
        }
    }
    return n ? sum / n : 0;
}

void RoomLightModel::setOn(int row, bool on)
{
    if (row < 0 || row >= m_items.size())
        return;
    if (m_items[row].on == on)
        return;
    m_items[row].on = on;
    emit dataChanged(index(row), index(row), { OnRole });
    emit summaryChanged();
}

void RoomLightModel::setBrightness(int row, int brightness)
{
    if (row < 0 || row >= m_items.size())
        return;
    brightness = qBound(1, brightness, 100);
    if (m_items[row].brightness == brightness)
        return;
    m_items[row].brightness = brightness;
    emit dataChanged(index(row), index(row), { BrightnessRole });
    emit summaryChanged();
}

void RoomLightModel::setWarmth(int row, int warmth)
{
    if (row < 0 || row >= m_items.size())
        return;
    warmth = qBound(0, warmth, 100);
    if (m_items[row].warmth == warmth)
        return;
    m_items[row].warmth = warmth;
    emit dataChanged(index(row), index(row), { WarmthRole });
}

void RoomLightModel::toggle(int row)
{
    if (row < 0 || row >= m_items.size())
        return;
    setOn(row, !m_items[row].on);
}

void RoomLightModel::allOff()
{
    for (int i = 0; i < m_items.size(); ++i)
        m_items[i].on = false;
    emit dataChanged(index(0), index(m_items.size() - 1), { OnRole });
    emit summaryChanged();
}

void RoomLightModel::allOn()
{
    for (int i = 0; i < m_items.size(); ++i)
        m_items[i].on = true;
    emit dataChanged(index(0), index(m_items.size() - 1), { OnRole });
    emit summaryChanged();
}


void RoomLightModel::addZone(const QString &name)
{
    Light light_zone;
    light_zone.name = name.trimmed().isEmpty() ? QStringLiteral("New Zone") : name.trimmed();
    light_zone.brightness = 50.0;
    light_zone.on = false;
    light_zone.warmth = 50.0;

    const int row = m_items.size();
    beginInsertRows(QModelIndex(), row, row);
    m_items.append(light_zone);
    endInsertRows();
    emit summaryChanged();
}

void RoomLightModel::removeZone(int row)
{
    if (row < 0 || row >= m_items.size())
        return;
    beginRemoveRows(QModelIndex(), row, row);
    m_items.removeAt(row);
    endRemoveRows();
    emit summaryChanged();
}