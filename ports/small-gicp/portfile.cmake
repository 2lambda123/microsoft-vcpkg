vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO koide3/small_gicp
    REF v0.1.0
    SHA512 bdd0d1e39d25877e58b2753addbad082f2fdf3962809fe646cab8ba63438eff05e2276afb2803aaed0a3905e0251208e2faaf8c1c416b551ffbdd54b9743ddb6
    HEAD_REF master
)

vcpkg_cmake_configure(SOURCE_PATH ${SOURCE_PATH})
vcpkg_cmake_install()
vcpkg_cmake_config_fixup(
    PACKAGE_NAME small_gicp
    CONFIG_PATH lib/cmake/small_gicp
)
vcpkg_install_copyright(FILE_LIST "${SOURCE_PATH}/LICENSE")
file(REMOVE_RECURSE "${CURRENT_PACKAGES_DIR}/debug/include")

file(INSTALL "${CMAKE_CURRENT_LIST_DIR}/usage" DESTINATION "${CURRENT_PACKAGES_DIR}/share/${PORT}")