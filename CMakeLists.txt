cmake_minimum_required(VERSION 3.16)

project(TypeDrill VERSION 0.1 LANGUAGES CXX)

set(CMAKE_AUTOMOC ON)
set(CMAKE_CXX_STANDARD_REQUIRED ON)

# Find required Qt modules
find_package(Qt6 6.2 COMPONENTS Quick Sql REQUIRED)

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

    QML_FILES
        main.qml
        AddNewWordForm.qml
        HomePage.qml
        AddNewTableForm.qml
        PracticePage.qml
        PickTablePage.qml
        PracticeVerbs.qml
        PracticeTimeComponent.qml
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
    PRIVATE Qt6::Quick Qt6::Sql
)

# ✅ Android-specific deploy step (compatible with Felgo CI/CD)
if(ANDROID)
    qt_generate_deploy_qml_app_script(
        TARGET appTypeDrill
    )
endif()

# Install rules (for desktop platforms)
include(GNUInstallDirs)
install(TARGETS appTypeDrill
    BUNDLE DESTINATION .
    LIBRARY DESTINATION ${CMAKE_INSTALL_LIBDIR}
)
