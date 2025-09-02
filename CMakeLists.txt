cmake_minimum_required(VERSION 3.16)

project(TypeDrill VERSION 0.1 LANGUAGES CXX)

set(CMAKE_AUTOMOC ON)
set(CMAKE_CXX_STANDARD_REQUIRED ON)

# Find required Qt modules
find_package(Qt6 6.2 COMPONENTS Quick Sql Network REQUIRED)

# Define the executable target
qt_add_executable(appTypeDrill
    main.cpp
)

# Define QML module
qt_add_qml_module(appTypeDrill
    URI TypeDrill
    VERSION 1.0

    SOURCES
        backend.h
        backend.cpp
        database.h
        database.cpp
        filemanager.h
        filemanager.cpp
        settingsmanager.h
        settingsmanager.cpp

    QML_FILES
        main.qml
        HomePage.qml
        AddNewWordForm.qml
        AddNewTableForm.qml
        AddNewDatabaseForm.qml
        PracticePage.qml
        PracticeTimeComponent.qml
        CustomButton.qml
        ManageWordTableDatabasePage.qml
        ProfilePage.qml
        SettingsPage.qml
        CustomComboboxWithIcon.qml
        CustomButtonWithIcon.qml
        BrowsePage.qml
        CustomProccessBar.qml
        CustomTextInput.qml
        CustomSwitch.qml
        CustomCombobox.qml
        CustomPopupMessage.qml
        themes.js

    RESOURCES
        resourses/darkMode/50x50/browse.png
        resourses/darkMode/50x50/check.png
        resourses/darkMode/50x50/close.png
        resourses/darkMode/50x50/manage.png
        resourses/darkMode/50x50/menu.png
        resourses/darkMode/50x50/profile.png
        resourses/darkMode/50x50/question.png
        resourses/darkMode/50x50/settings.png
        resourses/darkMode/50x50/streak.png
        resourses/darkMode/50x50/back.png
        resourses/darkMode/50x50/pin.png

        resourses/lightMode/50x50/browse.png
        resourses/lightMode/50x50/check.png
        resourses/lightMode/50x50/close.png
        resourses/lightMode/50x50/manage.png
        resourses/lightMode/50x50/menu.png
        resourses/lightMode/50x50/profile.png
        resourses/lightMode/50x50/question.png
        resourses/lightMode/50x50/settings.png
        resourses/lightMode/50x50/streak.png
        resourses/lightMode/50x50/back.png
        resourses/lightMode/50x50/pin.png
        resourses/darkMode/50x50/download.png
        resourses/darkMode/50x50/upload.png
        resourses/lightMode/50x50/download.png
        resourses/lightMode/50x50/upload.png

)

# Set app properties for macOS/Windows
set_target_properties(appTypeDrill PROPERTIES
    MACOSX_BUNDLE_BUNDLE_VERSION ${PROJECT_VERSION}
    MACOSX_BUNDLE_SHORT_VERSION_STRING ${PROJECT_VERSION_MAJOR}.${PROJECT_VERSION_MINOR}
    MACOSX_BUNDLE TRUE
    WIN32_EXECUTABLE TRUE
)

# Link against Qt libraries
target_link_libraries(appTypeDrill
    PRIVATE Qt6::Quick Qt6::Sql Qt6::Network
)

if(ANDROID)
    # No deployment script needed — Felgo CI handles APK packaging internally
endif()

# Install rules (for desktop)
include(GNUInstallDirs)
install(TARGETS appTypeDrill
    BUNDLE DESTINATION .
    LIBRARY DESTINATION ${CMAKE_INSTALL_LIBDIR}
)
