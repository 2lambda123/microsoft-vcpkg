vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO ybainier/Hypodermic
    REF 0e0d85d70aa2f2391dfd84f8af4a3863d4fb1611 # v2.5.3
    SHA512 6fc3f9eca034a4de3f7086bd51e9ba11ee31c8ec000a3e0bdfc06db1f3c12a89b66793adf5d219441e680541e26acaef72d21f9dd0acf3f5fee3aa12d3fb7b4d
    HEAD_REF master
    PATCHES
        "disable_hypodermic_tests.patch"
)

vcpkg_configure_cmake(
    SOURCE_PATH ${SOURCE_PATH}
    PREFER_NINJA
)

vcpkg_install_cmake()

file(REMOVE_RECURSE
    ${CURRENT_PACKAGES_DIR}/lib
    ${CURRENT_PACKAGES_DIR}/debug
)


# Put the license file where vcpkg expects it
file(COPY ${SOURCE_PATH}/LICENSE DESTINATION ${CURRENT_PACKAGES_DIR}/share/hypodermic/)
file(RENAME ${CURRENT_PACKAGES_DIR}/share/hypodermic/LICENSE ${CURRENT_PACKAGES_DIR}/share/hypodermic/copyright)
