vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO log4cplus/log4cplus
    REF REL_2_0_7
    SHA512 FE5FCEB346AC19A6D953661A20E8AA02AB48E872F427D958EA99C62F534DDF1FA4511FFD67A662605B1F225E3A6C06B0EE2C1B0EB62DE3AA0316F47F778DF06D
    HEAD_REF master
)

vcpkg_from_github(
    OUT_SOURCE_PATH THREADPOOL_SOURCE_PATH
    REPO log4cplus/ThreadPool
    REF 3507796e172d36555b47d6191f170823d9f6b12c
    SHA512 6b46ce287d68fd0cda0c69fda739eaeda89e1ed4f086e28a591f4e50aaf80ee2defc28ee14a5bf65be005c1a6ec4f2848d5723740726c54d5cc1d20f8e98aa0c
    HEAD_REF master
)

file(
    COPY
        "${THREADPOOL_SOURCE_PATH}/COPYING"
        "${THREADPOOL_SOURCE_PATH}/example.cpp"
        "${THREADPOOL_SOURCE_PATH}/README.md"
        "${THREADPOOL_SOURCE_PATH}/ThreadPool.h"
    DESTINATION "${SOURCE_PATH}/threadpool"
)

vcpkg_check_features(
    OUT_FEATURE_OPTIONS FEATURE_OPTIONS
    FEATURES
        unicode UNICODE
)

vcpkg_cmake_configure(
    SOURCE_PATH "${SOURCE_PATH}"
    OPTIONS
        -DLOG4CPLUS_BUILD_TESTING=OFF
        -DLOG4CPLUS_BUILD_LOGGINGSERVER=OFF
        -DWITH_UNIT_TESTS=OFF
        -DLOG4CPLUS_ENABLE_DECORATED_LIBRARY_NAME=OFF
        ${FEATURE_OPTIONS}
)

vcpkg_cmake_install()

vcpkg_cmake_config_fixup(CONFIG_PATH lib/cmake/log4cplus)

vcpkg_copy_pdbs()

file(REMOVE_RECURSE "${CURRENT_PACKAGES_DIR}/debug/include")
file(REMOVE_RECURSE "${CURRENT_PACKAGES_DIR}/debug/share")

# Handle copyright
file(INSTALL "${SOURCE_PATH}/LICENSE" DESTINATION "${CURRENT_PACKAGES_DIR}/share/${PORT}" RENAME copyright)
