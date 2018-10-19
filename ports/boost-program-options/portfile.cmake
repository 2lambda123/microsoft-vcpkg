# Automatically generated by boost-vcpkg-helpers/generate-ports.ps1

include(vcpkg_common_functions)

vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO boostorg/program_options
    REF boost-1.68.0
    SHA512 debbeb71fd8b4b0a4cef0297b3de6f94758948a117eeff4ccb713ea733c2304ce5f0c17673a066c5faa8b87c3aa2e4602908c4d52d76e53d7c4c2120f76ab4f2
    HEAD_REF master
)

include(${CURRENT_INSTALLED_DIR}/share/boost-build/boost-modular-build.cmake)
boost_modular_build(SOURCE_PATH ${SOURCE_PATH})
include(${CURRENT_INSTALLED_DIR}/share/boost-vcpkg-helpers/boost-modular-headers.cmake)
boost_modular_headers(SOURCE_PATH ${SOURCE_PATH})
