# Automatically generated by scripts/boost/generate-ports.ps1

vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO boostorg/concept_check
    REF boost-1.74.0
    SHA512 ee083482c4bc41effcd1dc342c22f4d733a90ec12425bbdf328c62cf0df4259b220c18df2463ad6ec9586eb90b80b4bcc30c467fdd92d44135b7d1b169b55bac
    HEAD_REF master
)

include(${CURRENT_INSTALLED_DIR}/share/boost-vcpkg-helpers/boost-modular-headers.cmake)
boost_modular_headers(SOURCE_PATH ${SOURCE_PATH})
