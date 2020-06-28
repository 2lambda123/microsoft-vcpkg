vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO edenhill/librdkafka
    REF 3bdf2d05fad1ef699910f7f9e7152c58aa24375e   #v1.4.4
    SHA512 e5f0558cef63f172069f7dc004c54b71905dec64c67793d05cf1f63bdbb50b6452c29347ca32f224db62a0effbdd01b02b913913da4d9fac2a4d14f8119a3880
    HEAD_REF master
    PATCHES
        fix-arm64.patch
)

string(COMPARE EQUAL "${VCPKG_LIBRARY_LINKAGE}" "static" RDKAFKA_BUILD_STATIC)

vcpkg_check_features(OUT_FEATURE_OPTIONS FEATURE_OPTIONS
    lz4     ENABLE_LZ4_EXT
    ssl     WITH_SSL
    zlib    WITH_ZLIB
    zstd    WITH_ZSTD
    snappy WITH_SNAPPY
)

vcpkg_configure_cmake(
    SOURCE_PATH ${SOURCE_PATH}
    PREFER_NINJA
    OPTIONS
        -DRDKAFKA_BUILD_STATIC=${RDKAFKA_BUILD_STATIC}
        -DRDKAFKA_BUILD_EXAMPLES=OFF
        -DRDKAFKA_BUILD_TESTS=OFF
        -DWITH_BUNDLED_SSL=OFF
        ${FEATURE_OPTIONS}
    OPTIONS_DEBUG
        -DENABLE_DEVEL=ON
        -DENABLE_REFCNT_DEBUG=ON
        -DENABLE_SHAREDPTR_DEBUG=ON
        -DWITHOUT_OPTIMIZATION=ON
    OPTIONS_RELEASE
        -DENABLE_DEVEL=OFF
        -DENABLE_REFCNT_DEBUG=OFF
        -DENABLE_SHAREDPTR_DEBUG=OFF
        -DWITHOUT_OPTIMIZATION=OFF
)

vcpkg_install_cmake()

vcpkg_copy_pdbs()

vcpkg_fixup_cmake_targets(
    CONFIG_PATH lib/cmake/RdKafka
    TARGET_PATH share/rdkafka
)

if("lz4" IN_LIST FEATURES)
    vcpkg_replace_string(
        ${CURRENT_PACKAGES_DIR}/share/rdkafka/RdKafkaConfig.cmake
        "find_dependency(LZ4)"
        "include(\"\${CMAKE_CURRENT_LIST_DIR}/FindLZ4.cmake\")\n  find_dependency(LZ4)"
    )
endif()

file(REMOVE_RECURSE
    ${CURRENT_PACKAGES_DIR}/debug/include
    ${CURRENT_PACKAGES_DIR}/debug/share
)

if(VCPKG_LIBRARY_LINKAGE STREQUAL static)
    foreach(hdr rdkafka.h rdkafkacpp.h)
        vcpkg_replace_string(
            ${CURRENT_PACKAGES_DIR}/include/librdkafka/${hdr}
            "#ifdef LIBRDKAFKA_STATICLIB"
            "#if 1 // #ifdef LIBRDKAFKA_STATICLIB"
        )
    endforeach()
endif()

# Handle copyright
configure_file(${SOURCE_PATH}/LICENSES.txt ${CURRENT_PACKAGES_DIR}/share/${PORT}/copyright COPYONLY)

# Install usage
configure_file(${CMAKE_CURRENT_LIST_DIR}/usage ${CURRENT_PACKAGES_DIR}/share/${PORT}/usage @ONLY)

# CMake integration test
vcpkg_test_cmake(PACKAGE_NAME RdKafka)
