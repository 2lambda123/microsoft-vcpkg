# Automatically generated by scripts/boost/generate-ports.ps1

vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO boostorg/conversion
    REF boost-1.74.0
    SHA512 a4ade9b73f204699cee883f45091f5f8fae593d8f5e21601a770a5e78d529321971a745a9d9c90d84fd3388e7fa0ebff2e58fd8a4ccd7b70dd222e2889b23ed1
    HEAD_REF master
)

include(${CURRENT_INSTALLED_DIR}/share/boost-vcpkg-helpers/boost-modular-headers.cmake)
boost_modular_headers(SOURCE_PATH ${SOURCE_PATH})
