# HomeAuto

A professional Qt 6 / QML desktop GUI for a smart home automation system.

Dark, modern interface with a sidebar navigation and three control modules:

- **Lighting** — per-room on/off, brightness, and warm→cool color control
- **Watering** — irrigation zones with soil-moisture gauges, schedules, and live run status
- **Climate** — live per-room temperature & humidity with trend charts

> Sensor/actuator data is **simulated** in the C++ models (timer-driven), so the app runs fully standalone with no hardware attached.

## Screenshots

| Lighting | Watering | Climate |
|----------|----------|---------|
| Per-room lights | Zone irrigation | Temp & humidity |

## Features

### Lighting
- On/off toggle per room with live summary (active count, average brightness)
- Brightness slider (1–100%)
- Warm→Cool color slider with a live color preview tint
- All On / All Off shortcuts
- Add / remove rooms

### Watering
- Soil-moisture ring gauge per zone, color-coded by level
- Auto-schedule toggle (auto-irrigates when moisture drops below threshold)
- Adjustable watering duration
- Manual Water Now / Stop, with live countdown and flow rate
- Stop All shortcut
- Add / remove zones via dialog

### Climate
- Large temperature & humidity readouts per room, color-coded by temperature
- Live trend sparkline (rolling 48-sample history)
- Rising/falling/flat trend indicator, plus session min/max
- Add / remove rooms

## Requirements

- Qt 6.4+ (Quick, Qml, Gui, QuickControls2)
- CMake 3.16+
- A C++17 compiler
- Ninja (or any CMake generator)

On Ubuntu/Debian:

```bash
sudo apt install qt6-base-dev qt6-declarative-dev cmake ninja-build build-essential
```

## Build

```bash
cmake -S . -B build -G Ninja -DCMAKE_BUILD_TYPE=Release
cmake --build build
```

## Run

```bash
./build/appHomeAuto
```

### Optional environment helpers (for development)

| Variable | Effect |
|----------|--------|
| `HOMEAUTO_TAB=0\|1\|2` | Start on Lighting (0), Watering (1), or Climate (2) |
| `HOMEAUTO_SHOT=/path.png` | Render once and save a screenshot (works with `QT_QPA_PLATFORM=offscreen` for headless capture) |

Example headless screenshot:

```bash
QT_QPA_PLATFORM=offscreen HOMEAUTO_TAB=2 HOMEAUTO_SHOT=/tmp/climate.png ./build/appHomeAuto
```

## Project structure

```
QT_GUI/
├── CMakeLists.txt
├── main.cpp                       # App entry, QML engine bootstrap
├── backend/                       # C++ data models (QAbstractListModel)
│   ├── RoomLightModel.*           # Lighting rooms
│   ├── WateringZoneModel.*        # Irrigation zones + simulation timer
│   └── ClimateModel.*             # Climate rooms + history simulation
└── qml/
    ├── Main.qml                   # Window, sidebar, top bar, page stack
    ├── Theme.qml                  # Singleton design tokens (colors, type, spacing)
    ├── components/                # Reusable widgets
    │   ├── AppIcon.qml            # Canvas-drawn vector icons (no image assets)
    │   ├── Card.qml, Sidebar.qml, NavButton.qml, PageHeader.qml
    │   ├── PrimaryButton.qml, StyledSlider.qml, StyledSwitch.qml
    │   ├── RingGauge.qml, Sparkline.qml, StatPill.qml
    └── pages/
        ├── LightsPage.qml
        ├── WateringPage.qml
        └── ClimatePage.qml
```

## Architecture notes

- The C++ models expose data to QML via roles and `Q_INVOKABLE` methods (toggle, set values, add/remove). They are registered with `QML_ELEMENT` and instantiated once in `Main.qml`.
- All visuals are styled in QML against the `Theme` singleton — change colors/spacing/typography in one place.
- Charts and icons are drawn with QML `Canvas`, so the app needs **no external image assets** and **no Qt Charts** module.

## Connecting real hardware

Replace the simulation in each model's timer `tick()` with reads from your transport (e.g. MQTT, Modbus, GPIO, REST), and route the `Q_INVOKABLE` setters (`setOn`, `start`, `setDuration`, …) to actuator commands.

## License

MIT — see [LICENSE](LICENSE).

Covers this repository's own code. Qt itself is licensed separately (LGPLv3 or commercial);
shipping this app on a device has obligations of its own — see `DECISIONS.md` D17 in the OTA
platform workspace.
