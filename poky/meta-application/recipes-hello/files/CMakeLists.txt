cmake_minimum_required(VERSION 3.10)
project(hellocmake)

# Specify the C++ standard
set(CMAKE_CXX_STANDARD 11)
set(CMAKE_CXX_STANDARD_REQUIRED True)

# Specify path
set(INCLUDE include)
set(SOURCE
	source/echo.cpp
	source/hello.cpp
)

# Include directories
include_directories(${INCLUDE})

# Add the executable
add_executable(hellocmake ${SOURCE})

# Install
install(TARGETS hellocmake RUNTIME DESTINATION bin)

