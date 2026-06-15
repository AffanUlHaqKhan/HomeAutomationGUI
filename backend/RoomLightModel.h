#pragma once

#include <QAbstractListModel>
#include <QVector>
#include <QtQml/qqmlregistration.h>

class RoomLightModel : public QAbstractListModel
{
    Q_OBJECT
    QML_ELEMENT
    Q_PROPERTY(int onCount READ onCount NOTIFY summaryChanged)
    Q_PROPERTY(int count READ count NOTIFY summaryChanged)
    Q_PROPERTY(int averageBrightness READ averageBrightness NOTIFY summaryChanged)

public:
    enum Roles {
        NameRole = Qt::UserRole + 1,
        IconRole,
        OnRole,
        BrightnessRole,   // 1..100
        WarmthRole        // 0 (warm) .. 100 (cool)
    };
    Q_ENUM(Roles)

    explicit RoomLightModel(QObject *parent = nullptr);

    int rowCount(const QModelIndex &parent = QModelIndex()) const override;
    QVariant data(const QModelIndex &index, int role) const override;
    QHash<int, QByteArray> roleNames() const override;

    int onCount() const;
    int count() const { return m_items.size(); }
    int averageBrightness() const;

    Q_INVOKABLE void setOn(int row, bool on);
    Q_INVOKABLE void setBrightness(int row, int brightness);
    Q_INVOKABLE void setWarmth(int row, int warmth);
    Q_INVOKABLE void toggle(int row);
    Q_INVOKABLE void allOff();
    Q_INVOKABLE void allOn();
    Q_INVOKABLE void addZone(const QString &name);
    Q_INVOKABLE void removeZone(int row);

signals:
    void summaryChanged();

private:
    struct Light {
        QString name;
        QString icon;
        bool on = false;
        int brightness = 70;
        int warmth = 30;
    };
    QVector<Light> m_items;
};
