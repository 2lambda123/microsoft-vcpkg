# Automatically generated by scripts/boost/generate-ports.ps1

vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO boostorg/format
    REF boost-1.78.0
    SHA512 5d104eaff0d91984c5ac712af1e53f0d73215dad4252b065dec119bbad5dde72a35bf23f56dc2f765902045ca94d5472c1ab15241ef631fdf784cd950a98e86f
    HEAD_REF master
)

include(${CURRENT_INSTALLED_DIR}/share/boost-vcpkg-helpers/boost-modular-headers.cmake)
boost_modular_headers(SOURCE_PATH ${SOURCE_PATH})
