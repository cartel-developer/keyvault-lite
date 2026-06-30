cmake_minimum_required(VERSION 3.16)

project(KeyVaultLite VERSION 1.0 LANGUAGES CXX)

set(CMAKE_CXX_STANDARD 17)
set(CMAKE_CXX_STANDARD_REQUIRED ON)
set(CMAKE_AUTOMOC ON)
set(CMAKE_AUTORCC ON)

find_package(Qt5 REQUIRED COMPONENTS Core Quick Qml Sql)

add_executable(KeyVaultLite
    main.cpp
    FormController.cpp
    FormController.h
    qml.qrc
)

target_link_libraries(KeyVaultLite
    PRIVATE
        Qt5::Core
        Qt5::Quick
        Qt5::Qml
        Qt5::Sql
)
