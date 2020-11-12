# Automatically generated by boost-vcpkg-helpers/generate-ports.ps1

vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO boostorg/type_traits
    REF boost-1.74.0
    SHA512 ac6e4482297f6f460912a211bdcdd273ca0ea907a598ebaa41ed9f060dc020691ce3ced05c684640deb2d4a7d96a5b5512aef5a44eb79f95e3616156d005f66b
    HEAD_REF master
)

include(${CURRENT_INSTALLED_DIR}/share/boost-vcpkg-helpers/boost-modular-headers.cmake)
boost_modular_headers(SOURCE_PATH ${SOURCE_PATH})
