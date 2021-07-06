vcpkg_check_linkage(ONLY_STATIC_LIBRARY)

set(GIFLIB_VERSION 5.2.1)

if (VCPKG_TARGET_IS_WINDOWS)
    set(ADDITIONAL_PATCH "fix-compile-error.patch")
endif()

vcpkg_from_sourceforge(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO "giflib"
    FILENAME "giflib-${GIFLIB_VERSION}.tar.gz"
    SHA512 4550e53c21cb1191a4581e363fc9d0610da53f7898ca8320f0d3ef6711e76bdda2609c2df15dc94c45e28bff8de441f1227ec2da7ea827cb3c0405af4faa4736
    PATCHES
        msvc-guard-unistd-h.patch
        ${ADDITIONAL_PATCH}
)

file(COPY ${CMAKE_CURRENT_LIST_DIR}/CMakeLists.txt DESTINATION ${SOURCE_PATH})

vcpkg_configure_cmake(
    SOURCE_PATH ${SOURCE_PATH}
    PREFER_NINJA
    OPTIONS_DEBUG
        -DGIFLIB_SKIP_HEADERS=ON
)

vcpkg_install_cmake()
vcpkg_copy_pdbs()

file(INSTALL ${SOURCE_PATH}/COPYING DESTINATION ${CURRENT_PACKAGES_DIR}/share/giflib RENAME copyright)
