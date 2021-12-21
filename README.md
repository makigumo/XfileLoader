# An Xfile Loader plugin for Hopper Disassembler

A basic loader plugin for Sharp X68000 executables (`*.x`).
Has option to mark DOS calls.

## Requirements

* [Hopper Disassembler](https://www.hopperapp.com)
* [M68k CPU plugin](https://github.com/makigumo/HopperSDK-v4/tree/master/Samples/M68kCPU) for disassembling

## Building

* build with Xcode
* or, via `xcodebuild`
* or, using *cmake*
    ```
    mkdir build
    cd build
    cmake ..
    make
    make install
    ```
### Linux

The Linux build requires the compilation of the Hopper SDK.
Please also refer the official [SDK Documentation](https://github.com/makigumo/HopperSDK-v4/blob/master/SDK%20Documentation.pdf). 

#### Compile SDK

* download and extract the Hopper SDK from https://hopperapp.com
    ```
    mkdir HopperSDK
    cd HopperSDK
    unzip HopperSDK-*.zip # your downloaded SDK file
    ```
* build the SDK
    ```
    cd Linux
    ./install.sh
    ```
* add the newly created bin-path to your `PATH`
    ```
    export PATH="$PATH":gnustep-Linux-x86_64/bin/
    ```

#### Build plugin

* follow the instructions for building with *cmake*
* or, run
    ```
    ./build.sh
    ```

### Linux (Docker)

A docker image with a precompiled Hopper SDK for Linux is also available, just run

```
./docker/linux-build.sh
```
