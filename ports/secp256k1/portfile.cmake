vcpkg_check_linkage(ONLY_STATIC_LIBRARY)

vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO "bitcoin-core/secp256k1"
    REF "44c2452fd387f7ca604ab42d73746e7d3a44d8a2"
    SHA512 1c1969b663843c71cba0148b14430bd2417b63a6ca7d6940585844b73aee2642622b080541ad3a1712390640f305f5bb1e251985d59674e1ded9cb4688f7830d
)

file(COPY ${CURRENT_PORT_DIR}/libsecp256k1-config.h DESTINATION ${SOURCE_PATH})
file(COPY ${CMAKE_CURRENT_LIST_DIR}/CMakeLists.txt DESTINATION ${SOURCE_PATH})

vcpkg_configure_cmake(
    SOURCE_PATH ${SOURCE_PATH}
    PREFER_NINJA
    OPTIONS_DEBUG
        -DINSTALL_HEADERS=OFF
)

vcpkg_install_cmake()
vcpkg_fixup_cmake_targets(CONFIG_PATH share/unofficial-${PORT} TARGET_PATH share/unofficial-${PORT})

file(REMOVE_RECURSE "${CURRENT_PACKAGES_DIR}/debug/share")
configure_file(${CMAKE_CURRENT_LIST_DIR}/secp256k1-config.cmake ${CURRENT_PACKAGES_DIR}/share/unofficial-${PORT}/unofficial-secp256k1-config.cmake @ONLY)
file(INSTALL ${SOURCE_PATH}/COPYING DESTINATION ${CURRENT_PACKAGES_DIR}/share/${PORT} RENAME copyright)
