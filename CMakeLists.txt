cmake_minimum_required(VERSION 3.16)

project(HomeAuto VERSION 1.0 LANGUAGES CXX)

set(CMAKE_CXX_STANDARD 17)
set(CMAKE_CXX_STANDARD_REQUIRED ON)
set(CMAKE_AUTOMOC ON)

find_package(Qt6 6.4 REQUIRED COMPONENTS Quick Gui Qml QuickControls2)

qt_standard_project_setup(REQUIRES 6.4)

qt_add_executable(appHomeAuto
    main.cpp
)

# Must be set before qt_add_qml_module so the generated qmldir marks it singleton.
set_source_files_properties(qml/Theme.qml PROPERTIES QT_QML_SINGLETON_TYPE TRUE)

qt_add_qml_module(appHomeAuto
    URI HomeAuto
    VERSION 1.0
    QML_FILES
        qml/Main.qml
        qml/Theme.qml
        qml/components/AppIcon.qml
        qml/components/Card.qml
        qml/components/Sidebar.qml
        qml/components/NavButton.qml
        qml/components/PrimaryButton.qml
        qml/components/StyledSlider.qml
        qml/components/StyledSwitch.qml
        qml/components/RingGauge.qml
        qml/components/Sparkline.qml
        qml/components/PageHeader.qml
        qml/components/StatPill.qml
        qml/pages/LightsPage.qml
        qml/pages/WateringPage.qml
        qml/pages/ClimatePage.qml
    SOURCES
        backend/RoomLightModel.h
        backend/RoomLightModel.cpp
        backend/WateringZoneModel.h
        backend/WateringZoneModel.cpp
        backend/ClimateModel.h
        backend/ClimateModel.cpp
)

target_include_directories(appHomeAuto PRIVATE ${CMAKE_CURRENT_SOURCE_DIR}/backend)

target_link_libraries(appHomeAuto PRIVATE
    Qt6::Quick
    Qt6::Gui
    Qt6::Qml
    Qt6::QuickControls2
)
