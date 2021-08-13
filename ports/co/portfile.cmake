vcpkg_check_linkage(ONLY_STATIC_LIBRARY)

vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO idealvin/co
    REF 82b9f75dcd114c69d2b9c2c5a13ce2c3b95ba99f #v2.0.1
    SHA512 ec33c5b920adf8b5e5500ed7c9768bd595ba2b568b604f26f953ddb5d04e411e8a2ea05b213595a44cafbadf90c1e1661208855301b2b47295ccc6e20f36e8d8
    HEAD_REF master
)

vcpkg_check_features(OUT_FEATURE_OPTIONS FEATURE_OPTIONS
    FEATURES
        libcurl    WITH_LIBCURL
        openssl    WITH_OPENSSL

vcpkg_cmake_configure(
    SOURCE_PATH "${SOURCE_PATH}"
)

vcpkg_cmake_install()

file(REMOVE_RECURSE
    "${CURRENT_PACKAGES_DIR}/debug/include"
    "${CURRENT_PACKAGES_DIR}/debug/share"
)

file(INSTALL "${SOURCE_PATH}/LICENSE.md" DESTINATION "${CURRENT_PACKAGES_DIR}/share/${PORT}" RENAME copyright)
