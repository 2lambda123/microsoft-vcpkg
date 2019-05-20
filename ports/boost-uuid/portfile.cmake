# Automatically generated by boost-vcpkg-helpers/generate-ports.ps1

include(vcpkg_common_functions)

vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO boostorg/uuid
    REF boost-1.70.0
    SHA512 8fa80562f79b6192d7086add50a6c89996106161df0e43a5738e460253cdb7f94c3a941e72fbce49c0ae5eca67429ca6eb42e08af647832941b624a82160e9cf
    HEAD_REF master
)

include(${CURRENT_INSTALLED_DIR}/share/boost-vcpkg-helpers/boost-modular-headers.cmake)
boost_modular_headers(SOURCE_PATH ${SOURCE_PATH})
