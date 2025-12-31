# Makefile for Wobble - organic movement oscillator for disting NT
#
# Dual build targets:
#   make hardware - Build ARM .o for disting NT hardware
#   make test     - Build native .dylib/.so for desktop testing in VCV Rack nt_emu
#   make clean    - Clean build artifacts

# Project configuration
PROJECT = wobble
DISTINGNT_API = distingNT_API
FAUST_ARCH = faust
FAUST_SCRIPTS = $(DISTINGNT_API)/faust

# Source files
DSP_FILE = $(PROJECT).dsp
GENERATED_CPP = build/$(PROJECT).cpp

# Include paths
INCLUDES = -I$(DISTINGNT_API)/include

# Compiler flags - common
CXXFLAGS_COMMON = -std=c++11 -Wall -fno-exceptions

# Compiler flags - hardware (ARM Cortex-M7)
CXX_ARM = arm-none-eabi-c++
CXXFLAGS_ARM = $(CXXFLAGS_COMMON) \
	-mcpu=cortex-m7 \
	-mfpu=fpv5-d16 \
	-mfloat-abi=hard \
	-mthumb \
	-Os \
	-fPIC

# Compiler flags - desktop test
UNAME_S := $(shell uname -s)
ifeq ($(UNAME_S),Darwin)
    CXX_TEST = clang++
    DYLIB_EXT = dylib
    DYLIB_FLAGS = -dynamiclib -undefined dynamic_lookup
else
    CXX_TEST = g++
    DYLIB_EXT = so
    DYLIB_FLAGS = -shared
endif

CXXFLAGS_TEST = $(CXXFLAGS_COMMON) -O2 -fPIC -DNT_EMU_TEST

# Output directories
PLUGINS_DIR = plugins
BUILD_DIR = build

# Targets
.PHONY: all hardware test clean generate

all: hardware test

# Generate C++ from Faust DSP
$(GENERATED_CPP): $(DSP_FILE) $(FAUST_ARCH)/nt_arch.cpp | $(BUILD_DIR)
	faust -a $(FAUST_ARCH)/nt_arch.cpp -uim -nvi -mem -o $@ $<
	python3 $(FAUST_SCRIPTS)/remove_small_arrays.py $@
	python3 $(FAUST_ARCH)/apply_metadata.py $@

generate: $(GENERATED_CPP)

# Hardware target - ARM .o for disting NT
hardware: $(PLUGINS_DIR)/$(PROJECT).o

$(PLUGINS_DIR)/$(PROJECT).o: $(GENERATED_CPP) | $(PLUGINS_DIR)
	$(CXX_ARM) $(CXXFLAGS_ARM) $(INCLUDES) -c -o $@ $<
	@echo "Hardware build complete: $@"
	@ls -lh $@

# Test target - native .dylib/.so for VCV Rack nt_emu
test: $(PLUGINS_DIR)/$(PROJECT).$(DYLIB_EXT)

$(PLUGINS_DIR)/$(PROJECT).$(DYLIB_EXT): $(GENERATED_CPP) | $(PLUGINS_DIR)
	$(CXX_TEST) $(CXXFLAGS_TEST) $(INCLUDES) $(DYLIB_FLAGS) -o $@ $<
	@echo "Desktop test build complete: $@"
	@ls -lh $@

# Create output directories
$(PLUGINS_DIR):
	mkdir -p $(PLUGINS_DIR)

$(BUILD_DIR):
	mkdir -p $(BUILD_DIR)

# Clean build artifacts
clean:
	rm -rf $(PLUGINS_DIR) $(BUILD_DIR)
	@echo "Build artifacts cleaned"
