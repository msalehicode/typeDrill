cmake_minimum_required(VERSION 3.16)

project(TypeDrill VERSION 0.1 LANGUAGES CXX)

set(CMAKE_AUTOMOC ON)
set(CMAKE_CXX_STANDARD_REQUIRED ON)

# Find required Qt modules
find_package(Qt6 6.2 COMPONENTS Quick Sql Network Charts Core Gui Qml REQUIRED)


# Define the executable target
qt_add_executable(appTypeDrill
    main.cpp
)

# Define QML module
qt_add_qml_module(appTypeDrill
    URI TypeDrill
    VERSION 1.22.6

    SOURCES
        include/backend.h
        include/database.h
        include/filemanager.h
        include/settingsmanager.h
        src/filemanager.cpp
        src/database.cpp
        src/backend.cpp
        src/settingsmanager.cpp

    QML_FILES
        main.qml
        themes.js

        # pages
        ManageWordTableDatabasePage.qml
        BrowsePage.qml
        ProfilePage.qml
        SettingsPage.qml
        PracticePage.qml
        HomePage.qml

        ActivityStats.qml

        # forms
        forms/RemoveDatabaseForm.qml
        forms/AddNewWordForm.qml
        forms/AddNewTableForm.qml
        forms/AddNewDatabaseForm.qml
        forms/ModifyWordForm.qml

        # practiceModes
        practiceModes/flashcardPractice.qml
        practiceModes/typePractice.qml

        # components
        CustomComponents/qmldir
        CustomComponents/CustomButton.qml
        CustomComponents/CustomComboboxWithIcon.qml
        CustomComponents/CustomButtonWithIcon.qml
        CustomComponents/CustomProccessBar.qml
        CustomComponents/CustomTextInput.qml
        CustomComponents/CustomSwitch.qml
        CustomComponents/CustomCombobox.qml
        CustomComponents/CustomPopupMessage.qml
        CustomComponents/CustomSwitchText.qml
        CustomComponents/CustomTimer.qml
        CustomComponents/CustomPopupMenu.qml


    RESOURCES
        resourses/lightMode/50x50/browse.png resourses/darkMode/50x50/browse.png
        resourses/lightMode/50x50/check.png resourses/darkMode/50x50/check.png
        resourses/lightMode/50x50/close.png resourses/darkMode/50x50/close.png
        resourses/lightMode/50x50/manage.png resourses/darkMode/50x50/manage.png
        resourses/lightMode/50x50/profile.png resourses/darkMode/50x50/profile.png
        resourses/lightMode/50x50/question.png resourses/darkMode/50x50/question.png
        resourses/lightMode/50x50/settings.png resourses/darkMode/50x50/settings.png
        resourses/lightMode/50x50/streak.png resourses/darkMode/50x50/streak.png
        resourses/lightMode/50x50/back.png resourses/darkMode/50x50/back.png
        resourses/lightMode/50x50/pin.png resourses/darkMode/50x50/pin.png
        resourses/lightMode/50x50/upload.png resourses/darkMode/50x50/upload.png
        resourses/lightMode/50x50/download.png resourses/darkMode/50x50/download.png
        resourses/lightMode/50x50/search.png resourses/darkMode/50x50/search.png
        resourses/lightMode/50x50/save.png resourses/darkMode/50x50/save.png
        resourses/lightMode/50x50/menu.png resourses/darkMode/50x50/menu.png
        resourses/lightMode/50x50/menubar.png resourses/darkMode/50x50/menubar.png
        resourses/lightMode/50x50/modify.png resourses/darkMode/50x50/modify.png
        resourses/lightMode/50x50/delete.png resourses/darkMode/50x50/delete.png
        resourses/lightMode/50x50/archive.png resourses/darkMode/50x50/archive.png
        resourses/lightMode/50x50/hide.png resourses/darkMode/50x50/hide.png
        resourses/lightMode/50x50/eye.png resourses/darkMode/50x50/eye.png
)

# Set app properties for macOS/Windows
set_target_properties(appTypeDrill PROPERTIES
    MACOSX_BUNDLE_BUNDLE_VERSION ${PROJECT_VERSION}
    MACOSX_BUNDLE_SHORT_VERSION_STRING ${PROJECT_VERSION_MAJOR}.${PROJECT_VERSION_MINOR}
    MACOSX_BUNDLE TRUE
    WIN32_EXECUTABLE TRUE
)

# Link against Qt libraries
target_link_libraries(appTypeDrill PRIVATE
    Qt6::Quick
    Qt6::Sql
    Qt6::Network

    Qt6::Charts
    Qt6::Core
    Qt6::Gui
    Qt6::Qml
)

# Install rules (for desktop)
include(GNUInstallDirs)
install(TARGETS appTypeDrill
    BUNDLE DESTINATION .
    LIBRARY DESTINATION ${CMAKE_INSTALL_LIBDIR}
)
