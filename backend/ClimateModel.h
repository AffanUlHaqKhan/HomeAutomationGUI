#pragma once

#include <QAbstractListModel>
#include <QVector>
#include <QTimer>
#include <QtQml/qqmlregistration.h>

class ClimateModel : public QAbstractListModel
{
    Q_OBJECT
    QML_ELEMENT
    Q_PROPERTY(int count READ count NOTIFY summaryChanged)
    Q_PROPERTY(QString avgTemperature READ avgTemperature NOTIFY summaryChanged)
    Q_PROPERTY(int avgHumidity READ avgHumidity NOTIFY summaryChanged)

public:
    enum Roles {
        NameRole = Qt::UserRole + 1,
        TemperatureRole,   // °C, one decimal as string
        HumidityRole,      // %
        TempHistoryRole,   // QVariantList<double>
        HumHistoryRole,    // QVariantList<double>
        TempMinRole,
        TempMaxRole,
        TrendRole          // -1 down, 0 flat, +1 up (temperature)
    };
    Q_ENUM(Roles)

    explicit ClimateModel(QObject *parent = nullptr);

    int rowCount(const QModelIndex &parent = QModelIndex()) const override;
    QVariant data(const QModelIndex &index, int role) const override;
    QHash<int, QByteArray> roleNames() const override;

    int count() const { return m_items.size(); }
    QString avgTemperature() const;
    int avgHumidity() const;

    Q_INVOKABLE void addZone(const QString &name);
    Q_INVOKABLE void removeZone(int row);

signals:
    void summaryChanged();

private:
    void tick();

    static constexpr int kHistory = 48;

    struct Room {
        QString name;
        double temperature = 21.0;
        double humidity = 45.0;
        QVector<double> temperatureHistory;
        QVector<double> humidityHistory;
        int trend = 0;
    };
    QVector<Room> m_items;
    QTimer m_timer;
};
