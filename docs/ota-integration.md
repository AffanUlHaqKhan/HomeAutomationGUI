# OTA / embedded integration

This app is the device HMI in an OSTree-based OTA platform. It is built by
`meta-ota-platform` (recipe `recipes-qt/homeautomationgui/homeautomationgui_git.bb`) and
installed into a read-only OSTree rootfs.

Nothing here affects the desktop build — `cmake -S . -B build && ./build/appHomeAuto` keeps
working exactly as documented in the main README.

---

## Constraints the target imposes

### 1. `/usr` is read-only

OSTree mounts `/usr` read-only, permanently. Today the app stores nothing (all model data is
simulated in memory), so this costs nothing. It becomes relevant the moment real persistence is
added:

| Data | Location | Notes |
|---|---|---|
| Settings, databases, caches, logs | `/var/lib/homeautomationgui/` | persistent, untouched by OS updates |
| Shipped default config | `/etc/homeautomationgui/` | 3-way merged on update |
| Binary + compiled QML resources | `/usr/bin/appHomeAuto` | read-only, replaced wholesale on update |

`QSettings` with `setOrganizationName("HomeAuto")` will try to write under `$XDG_CONFIG_HOME`,
which is unset for a systemd service — it must be pointed at `/var` explicitly (the systemd
unit in `meta-ota-platform` sets `XDG_*` for this reason).

Avoid writing config the app itself changes into `/etc`: OSTree 3-way merges that directory on
update, so a file the app rewrote *and* a new commit changed resolves in a way that silently
drops one of the two. `/etc` is for config a human edits.

### 2. Install rules must stay correct

`install(TARGETS appHomeAuto RUNTIME DESTINATION ${CMAKE_INSTALL_BINDIR})` at the bottom of
`CMakeLists.txt` is what the Yocto recipe relies on. `qt_add_qml_module` compiles the QML into
the binary's resources, so no QML files ship separately — if that ever changes (e.g. switching
to a QML plugin or loading files from disk), the install rules and the recipe's `FILES:${PN}`
must be updated together, or the app will start on the desktop and fail on the device.

### 3. Version reporting

`APP_VERSION` comes from `project(HomeAuto VERSION 1.0 ...)` and is set on the
`QGuiApplication`. `ota-agent` reports it to the server in every heartbeat, and it is what the
fleet dashboard shows as the running app version. Bump `VERSION` in `CMakeLists.txt` with
releases, or the dashboard lies.

### 4. A crash loop rolls the device back — on purpose

`homeautomationgui.service` is in the agent's healthcheck list. If this app cannot stay running
after an OS update, the device reboots into the previous deployment.

Correct for a genuinely broken update. Wrong for a transient problem. So: never exit on a
condition that is not the app's fault — a missing sensor, an unreachable backend, a failed
network call. Degrade in the UI instead. Right now the models are fully simulated, so the app
cannot fail this way; keep that property when the simulation in each model's `tick()` is
replaced with real hardware transport.

### 5. Graphics platform

The systemd unit sets `QT_QPA_PLATFORM=eglfs` by default. It must match the BSP's graphics
stack — a mismatch gives a black screen with a perfectly "active" service. `wayland` or
`linuxfb` may be correct instead depending on the board.

`QQuickStyle::setStyle("Basic")` is already the right choice for embedded: no desktop style
dependencies.

---

## Building for the target

### Cross-compile with the Yocto SDK (fast iteration)

```bash
# in the yocto build dir
bitbake ota-image -c populate_sdk
./tmp/deploy/sdk/*.sh -d ~/ota-sdk

source ~/ota-sdk/environment-setup-*
cmake -B build-cross -DCMAKE_BUILD_TYPE=Release
cmake --build build-cross -j
scp build-cross/appHomeAuto root@device:/tmp && ssh root@device /tmp/appHomeAuto
```

Use `ota-image-dev`, which has ssh and `debug-tweaks`. This avoids a full image rebuild per
UI change.

### In the image

```bash
bitbake homeautomationgui     # package only
bitbake ota-image             # full image
```

---

## Qt modules required

`Quick`, `Gui`, `Qml`, `QuickControls2`. In Qt 6, Quick Controls ships inside the
`qtdeclarative` module, so the image needs `qtbase` and `qtdeclarative` only.

No `qtsvg` and no Qt Charts: icons and charts are drawn with QML `Canvas`. Keep it that way —
image size is update bandwidth for every device in the fleet.

---

## Optional: showing update status on screen

`ota-agent` exposes a local unix socket (`/run/ota-agent.sock`, line-delimited JSON) so the HMI
can show "downloading 42%" or "restart required", and let the user defer a reboot. Protocol is
in the `ota-agent` README.

If added, keep it in its own page/component with a small C++ client class. The socket may not
exist (dev builds, agent disabled), and this is the only place the app is coupled to the OTA
system.
