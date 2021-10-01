# Automatically generated by scripts/boost/generate-ports.ps1

vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO boostorg/describe
    REF boost-1.77.0
    SHA512 70b9283fb106ec99fea1cf72400f813abf92b44e74f1bd18411201e96ddd78b0f244bc445bf304a2259da28a2a119d20bc89e50b19852cf2fd8c45d2ba99a302
    HEAD_REF master
)

include(${CURRENT_INSTALLED_DIR}/share/boost-vcpkg-helpers/boost-modular-headers.cmake)
boost_modular_headers(SOURCE_PATH ${SOURCE_PATH})
