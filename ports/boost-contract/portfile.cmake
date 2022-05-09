# Automatically generated by scripts/boost/generate-ports.ps1

vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO boostorg/contract
    REF boost-1.79.0
    SHA512 511df371ee4c1bc9e443a4df1c1156138187f94b549df0944cc46613bf3ce07e7002d3003a41385b7e0f43326590ae4d932a15fdf0cc4d883b4be05ce79c3a94
    HEAD_REF master
)

include(${CURRENT_HOST_INSTALLED_DIR}/share/boost-build/boost-modular-build.cmake)
boost_modular_build(SOURCE_PATH ${SOURCE_PATH})
include(${CURRENT_INSTALLED_DIR}/share/boost-vcpkg-helpers/boost-modular-headers.cmake)
boost_modular_headers(SOURCE_PATH ${SOURCE_PATH})
