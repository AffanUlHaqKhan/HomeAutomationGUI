pragma Singleton
import QtQuick

QtObject {
    // Surfaces
    readonly property color bg:          "#0e1320"
    readonly property color bgElevated:  "#161d2e"
    readonly property color card:        "#1b2436"
    readonly property color cardHover:   "#212c42"
    readonly property color sidebar:     "#121826"
    readonly property color border:      "#2a3650"

    // Text
    readonly property color text:        "#eef2fb"
    readonly property color textMuted:   "#8a97b4"
    readonly property color textFaint:   "#5b6884"

    // Accents
    readonly property color accent:      "#4f8cff"
    readonly property color accentSoft:  "#2b3c63"
    readonly property color amber:       "#ffb454"
    readonly property color teal:        "#2dd4bf"
    readonly property color green:       "#43d17a"
    readonly property color red:         "#ff5f6e"
    readonly property color cyan:        "#38bdf8"
    readonly property color violet:      "#a78bfa"

    // Geometry
    readonly property int radius:        14
    readonly property int radiusSmall:   9
    readonly property int spacing:       16
    readonly property int pagePadding:   28

    // Typography
    // "Segoe UI" exists only on Windows dev machines. An unmatched family is
    // normally harmless -- Qt substitutes the default -- but on a minimal
    // embedded rootfs with no font files at all there is nothing to fall back
    // to and every glyph renders as a tofu box. Resolve against what is really
    // installed; "" means "whatever Qt picks".
    // Empty means "the platform's default UI font", which is Segoe UI on
    // Windows and DejaVu Sans on the device image -- so both look right
    // without naming a family that only exists on one of them.
    readonly property string fontFamily: "Segoe UI"
    readonly property int fontTiny:      11
    readonly property int fontSmall:     13
    readonly property int fontBody:      15
    readonly property int fontH3:        18
    readonly property int fontH2:        22
    readonly property int fontH1:        30
    readonly property int fontHuge:      44

    // Shared color helpers
    function moistureColor(v) {
        if (v < 30) return red;
        if (v < 50) return amber;
        if (v < 75) return teal;
        return cyan;
    }
    function tempColor(t) {
        if (t < 18) return cyan;
        if (t < 24) return green;
        if (t < 27) return amber;
        return red;
    }
}
