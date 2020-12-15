# Automatically generated by scripts/boost/generate-ports.ps1

vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO boostorg/variant2
    REF boost-1.74.0
    SHA512 b4778f3645d9073543f7bc030deb02ab66e0b341c37ba80e4afd8289e5e6cf8022481bdfacd29c62401772ded95b5924b16fe541196d67fa5b1f72a50347a502
    HEAD_REF master
)

include(${CURRENT_INSTALLED_DIR}/share/boost-vcpkg-helpers/boost-modular-headers.cmake)
boost_modular_headers(SOURCE_PATH ${SOURCE_PATH})
