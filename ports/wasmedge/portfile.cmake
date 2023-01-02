# Find the directory that contains "bin/clang"
# Note: Only clang-cl is supported on Windows
if(VCPKG_TARGET_IS_WINDOWS)
    vcpkg_find_acquire_program(CLANG)
    if(CLANG MATCHES "-NOTFOUND")
        message(FATAL_ERROR "Clang is required.")
    endif()
    get_filename_component(CLANG "${CLANG}" DIRECTORY)
    get_filename_component(CLANG "${CLANG}" DIRECTORY)
    if(NOT EXISTS "${CLANG}/bin/clang-cl.exe")
        message(FATAL_ERROR "Clang needs to be inside a bin directory.")
    endif()
endif()

vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO WasmEdge/WasmEdge
    REF c8d9a7fceb772ad882a70604c5fa0c8949796c1c
    SHA512 fd8c4f509c379eee5269ed2a6dbcda84ad1368592f141020b4f35ada3ea7f3a02b931c3080158c492a368caadf1389974514fed7a406e2e6456d3c72a7a2ad87
    HEAD_REF master
)

set(WASMEDGE_CMAKE_OPTIONS "")

list(APPEND WASMEDGE_CMAKE_OPTIONS "-DWASMEDGE_BUILD_AOT_RUNTIME=OFF")

if(VCPKG_LIBRARY_LINKAGE STREQUAL "dynamic")
    list(APPEND WASMEDGE_CMAKE_OPTIONS "-DWASMEDGE_BUILD_STATIC_LIB=OFF")
    list(APPEND WASMEDGE_CMAKE_OPTIONS "-DWASMEDGE_BUILD_SHARED_LIB=ON")
    list(APPEND WASMEDGE_CMAKE_OPTIONS "-DWASMEDGE_LINK_LLVM_STATIC=OFF")
    list(APPEND WASMEDGE_CMAKE_OPTIONS "-DWASMEDGE_LINK_TOOLS_STATIC=OFF")
else()
    list(APPEND WASMEDGE_CMAKE_OPTIONS "-DWASMEDGE_BUILD_STATIC_LIB=ON")
    list(APPEND WASMEDGE_CMAKE_OPTIONS "-DWASMEDGE_BUILD_SHARED_LIB=OFF")
    list(APPEND WASMEDGE_CMAKE_OPTIONS "-DWASMEDGE_LINK_LLVM_STATIC=ON")
    list(APPEND WASMEDGE_CMAKE_OPTIONS "-DWASMEDGE_LINK_TOOLS_STATIC=ON")
endif()

if("tools" IN_LIST FEATURES)
    list(APPEND WASMEDGE_CMAKE_OPTIONS "-DWASMEDGE_BUILD_TOOLS=ON")
else()
    list(APPEND WASMEDGE_CMAKE_OPTIONS "-DWASMEDGE_BUILD_TOOLS=OFF")
endif()

if("aot" IN_LIST FEATURES)
    list(APPEND WASMEDGE_CMAKE_OPTIONS "-DWASMEDGE_BUILD_AOT_RUNTIME=ON")
else()
    list(APPEND WASMEDGE_CMAKE_OPTIONS "-DWASMEDGE_BUILD_AOT_RUNTIME=OFF")
endif()

if("plugins" IN_LIST FEATURES)
    list(APPEND WASMEDGE_CMAKE_OPTIONS "-DWASMEDGE_BUILD_PLUGINS=ON")
else()
    list(APPEND WASMEDGE_CMAKE_OPTIONS "-DWASMEDGE_BUILD_PLUGINS=OFF")
endif()

# disabled due to build failure
list(APPEND WASMEDGE_CMAKE_OPTIONS "-DWASMEDGE_BUILD_EXAMPLE=OFF")

set(WASMEDGE_PLUGIN_WASI_NN_BACKEND "")

if("plugin-wasi-nn-backend-openvino" IN_LIST FEATURES)
    list(APPEND WASMEDGE_PLUGIN_WASI_NN_BACKEND "OpenVINO")
endif()
if("plugin-wasi-nn-backend-pytorch" IN_LIST FEATURES)
    list(APPEND WASMEDGE_PLUGIN_WASI_NN_BACKEND "PyTorch")
endif()
if("plugin-wasi-nn-backend-tensorflow-lite" IN_LIST FEATURES)
    list(APPEND WASMEDGE_PLUGIN_WASI_NN_BACKEND "TensorflowLite")
endif()

if(NOT WASMEDGE_PLUGIN_WASI_NN_BACKEND STREQUAL "")
    list(JOIN WASMEDGE_PLUGIN_WASI_NN_BACKEND "," WASMEDGE_PLUGIN_WASI_NN_BACKEND)
    list(APPEND WASMEDGE_CMAKE_OPTIONS "-WASMEDGE_PLUGIN_WASI_NN_BACKEND=${WASMEDGE_PLUGIN_WASI_NN_BACKEND}")
endif()

vcpkg_cmake_configure(
    SOURCE_PATH "${SOURCE_PATH}"
    OPTIONS ${WASMEDGE_CMAKE_OPTIONS}
    OPTIONS_RELEASE
        -DCMAKE_INSTALL_BINDIR=${CURRENT_PACKAGES_DIR}/tools
    OPTIONS_DEBUG
        -DCMAKE_INSTALL_BINDIR=${CURRENT_PACKAGES_DIR}/debug/tools
)

vcpkg_cmake_install()

file(INSTALL "${SOURCE_PATH}/LICENSE" DESTINATION "${CURRENT_PACKAGES_DIR}/share/${PORT}" RENAME copyright)

file(REMOVE_RECURSE "${CURRENT_PACKAGES_DIR}/debug/include")