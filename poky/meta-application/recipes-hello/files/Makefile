# Compiler
CXX = g++
CXXFLAGS = -Iinclude -std=c++11

#Source files
SOURCE = source/echo.cpp source/hello.cpp

# Output executable
TARGET = hellomake

# Build rule
all: $(TARGET)

$(TARGET): $(SOURCE)
	$(CXX) $(CXXFLAGS) -o $@ $^

# Clean rule
clean:
	rm -f $(TARGET)
