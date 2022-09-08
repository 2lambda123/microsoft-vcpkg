# Automatically generated by scripts/boost/generate-ports.ps1

vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO boostorg/describe
    REF boost-1.80.0
    SHA512 ede3b1723b30da1cb37042895d1c3e43e94d5ab67f0f78887da265e57f8e7cf5a535e3d56d637e8e251271c7fc645d17cdcb4acd568d613c0479e2bf49de1010
    HEAD_REF master
)

include(${CURRENT_INSTALLED_DIR}/share/boost-vcpkg-helpers/boost-modular-headers.cmake)
boost_modular_headers(SOURCE_PATH ${SOURCE_PATH})
