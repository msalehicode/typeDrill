cmake_minimum_required(VERSION 3.16)

project(TypeDrill VERSION 0.1 LANGUAGES CXX)

set(CMAKE_AUTOMOC ON)
set(CMAKE_CXX_STANDARD_REQUIRED ON)

find_package(Qt6 6.2 COMPONENTS Quick Sql REQUIRED)

qt_add_executable(appTypeDrill
    main.cpp
)

qt_add_qml_module(appTypeDrill
    URI TypeDrill
    VERSION 1.0
    QML_FILES main.qml
    SOURCES backend.h backend.cpp
    SOURCES database.h database.cpp
    QML_FILES
    QML_FILES AddNewWordForm.qml
    QML_FILES HomePage.qml
    QML_FILES AddNewTableForm.qml
    QML_FILES PracticePage.qml
    QML_FILES PickTablePage.qml
    QML_FILES PracticeVerbs.qml
)

# Qt for iOS sets MACOSX_BUNDLE_GUI_IDENTIFIER automatically since Qt 6.1.
# If you are developing for iOS or macOS you should consider setting an
# explicit, fixed bundle identifier manually though.
set_target_properties(appTypeDrill PROPERTIES
#    MACOSX_BUNDLE_GUI_IDENTIFIER com.example.appTypeDrill
    MACOSX_BUNDLE_BUNDLE_VERSION ${PROJECT_VERSION}
    MACOSX_BUNDLE_SHORT_VERSION_STRING ${PROJECT_VERSION_MAJOR}.${PROJECT_VERSION_MINOR}
    MACOSX_BUNDLE TRUE
    WIN32_EXECUTABLE TRUE
)

target_link_libraries(appTypeDrill
    PRIVATE Qt6::Quick Qt6::Sql)


include(GNUInstallDirs)
install(TARGETS appTypeDrill
    BUNDLE DESTINATION .
    LIBRARY DESTINATION ${CMAKE_INSTALL_LIBDIR})
