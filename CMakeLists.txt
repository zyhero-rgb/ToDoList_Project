cmake_minimum_required(VERSION 3.16)

project(ToDoList_Project VERSION 0.1 LANGUAGES CXX)

set(CMAKE_AUTOMOC ON)
set(CMAKE_CXX_STANDARD_REQUIRED ON)

find_package(Qt6 6.2 COMPONENTS Quick Sql REQUIRED)

qt_add_executable(appToDoList_Project
    main.cpp
)

qt_add_qml_module(appToDoList_Project
    URI ToDoList_Project
    VERSION 1.0
        QML_FILES main.qml
    SOURCES
        listmodel_manager.h listmodel_manager.cpp
        QML_FILES Src/appBar/AppBar.qml
        QML_FILES Src/bottomBar/BottomBar.qml
        QML_FILES Src/progressSection/ProgressSection.qml
        QML_FILES Src/taskInputPanel/TaskInputPanel.qml
        QML_FILES Src/taskItem/TaskItem.qml
        QML_FILES Src/taskListview/TaskListView.qml
        images/moon.png
        images/settings.png
        images/sun.png
)

# Qt for iOS sets MACOSX_BUNDLE_GUI_IDENTIFIER automatically since Qt 6.1.
# If you are developing for iOS or macOS you should consider setting an
# explicit, fixed bundle identifier manually though.
set_target_properties(appToDoList_Project PROPERTIES
#    MACOSX_BUNDLE_GUI_IDENTIFIER com.example.appToDoList_Project
    MACOSX_BUNDLE_BUNDLE_VERSION ${PROJECT_VERSION}
    MACOSX_BUNDLE_SHORT_VERSION_STRING ${PROJECT_VERSION_MAJOR}.${PROJECT_VERSION_MINOR}
    MACOSX_BUNDLE TRUE
    WIN32_EXECUTABLE TRUE
)

target_link_libraries(appToDoList_Project
    PRIVATE Qt6::Quick Qt6::Sql)

include(GNUInstallDirs)
install(TARGETS appToDoList_Project
    BUNDLE DESTINATION .
    LIBRARY DESTINATION ${CMAKE_INSTALL_LIBDIR})
