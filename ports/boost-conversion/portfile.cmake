# Automatically generated by boost-vcpkg-helpers/generate-ports.ps1

vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO boostorg/conversion
    REF boost-1.73.0
    SHA512 b452b75c97d183ce75e1923711de5338926a118ff947352753a9e2426a74bfb26b922b195d5fad52ff56ab1e1fd0e6a79bff3e672c67ab5f0bad7909369d3b38
    HEAD_REF master
)

include(${CURRENT_INSTALLED_DIR}/share/boost-vcpkg-helpers/boost-modular-headers.cmake)
boost_modular_headers(SOURCE_PATH ${SOURCE_PATH})
