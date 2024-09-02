vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO projectM-visualizer/projectm-eval
    REF "v${VERSION}"
    SHA512 "ff5abf4c5deb5a665ed116a1a7a56cfaa0acedc6c211b16ef0c118bc1316f256667681c999c31880dd3aa6aec5ab92ce0747c42ba1ab98ac5046b6ef015de935"
    HEAD_REF master
)

vcpkg_check_features(OUT_FEATURE_OPTIONS FEATURE_OPTIONS
    FEATURES
        ns-eel2 BUILD_NS_EEL_SHIM
)

vcpkg_cmake_configure(
    SOURCE_PATH "${SOURCE_PATH}"
    OPTIONS
        ${FEATURE_OPTIONS}
        -DCMAKE_DISABLE_FIND_PACKAGE_BISON=ON
        -DCMAKE_DISABLE_FIND_PACKAGE_FLEX=ON
)

vcpkg_cmake_install()

if("ns-eel2" IN_LIST FEATURES)
    vcpkg_cmake_config_fixup(
        PACKAGE_NAME "projectM-EvalMilkdrop"
        CONFIG_PATH "lib/cmake/projectM-EvalMilkdrop"
        DO_NOT_DELETE_PARENT_CONFIG_PATH
    )
endif()

vcpkg_cmake_config_fixup(
    PACKAGE_NAME "projectm-eval"
    CONFIG_PATH "lib/cmake/projectM-Eval"
)

vcpkg_fixup_pkgconfig()

file(REMOVE_RECURSE "${CURRENT_PACKAGES_DIR}/debug/include")

vcpkg_install_copyright(FILE_LIST "${SOURCE_PATH}/LICENSE.md")
file(INSTALL "${CMAKE_CURRENT_LIST_DIR}/usage" DESTINATION "${CURRENT_PACKAGES_DIR}/share/${PORT}")
