#pragma once

#include <QAbstractListModel>
#include <QVector>
#include <QTimer>
#include <QtQml/qqmlregistration.h>

class WateringZoneModel : public QAbstractListModel
{
    Q_OBJECT
    QML_ELEMENT
    Q_PROPERTY(int activeCount READ activeCount NOTIFY summaryChanged)
    Q_PROPERTY(int count READ count NOTIFY summaryChanged)
    Q_PROPERTY(int averageMoisture READ averageMoisture NOTIFY summaryChanged)

public:
    enum Roles {
        NameRole = Qt::UserRole + 1,
        MoistureRole,     // 0..100 %
        WateringRole,     // bool, currently running
        AutoRole,         // bool, auto schedule enabled
        DurationRole,     // minutes per cycle
        RemainingRole,    // seconds remaining in current run
        FlowRole          // L/min while running
    };
    Q_ENUM(Roles)

    explicit WateringZoneModel(QObject *parent = nullptr);

    int rowCount(const QModelIndex &parent = QModelIndex()) const override;
    QVariant data(const QModelIndex &index, int role) const override;
    QHash<int, QByteArray> roleNames() const override;

    int activeCount() const;
    int count() const { return m_items.size(); }
    int averageMoisture() const;

    Q_INVOKABLE void start(int row);
    Q_INVOKABLE void stop(int row);
    Q_INVOKABLE void setAuto(int row, bool en);
    Q_INVOKABLE void setDuration(int row, int minutes);
    Q_INVOKABLE void stopAll();
    Q_INVOKABLE void addZone(const QString &name);
    Q_INVOKABLE void removeZone(int row);

signals:
    void summaryChanged();

private:
    void tick();

    struct Zone {
        QString name;
        double  moisture = 50.0;
        bool    watering = false;
        bool    autoMode = true;
        int     duration = 10;     // minutes
        int     remaining = 0;     // seconds
        double  flow = 0.0;        // L/min
        double  threshold = 35.0;  // auto trigger below this
    };
    QVector<Zone> m_items;
    QTimer m_timer;
};
