cmake_minimum_required(VERSION 3.4.1)

add_library(emulator-lib SHARED src/main/cpp/emulator-lib.cpp )

find_library(log-lib log )

target_link_libraries(emulator-lib ${log-lib} )
