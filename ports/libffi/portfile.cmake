include(vcpkg_common_functions)

# Hopefully both PR will be merged soon
vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO driver1998/libffi
    REF bb00e92da36faa6e2182592336d6b5ef0a4f7b3c
    SHA512 1ac2a3d8aa680a9ca9d004ab23de2d950a455d3df703ec4d53a4294878659be9be46eea5564a1060615dc52d3296f73bcfa237b1107b08c81341bc79623cb86d
    HEAD_REF master
    PATCHES
        fix-defines.patch
)

file(COPY ${CMAKE_CURRENT_LIST_DIR}/CMakeLists.txt DESTINATION ${SOURCE_PATH})

vcpkg_configure_cmake(
    SOURCE_PATH ${SOURCE_PATH}
    PREFER_NINJA
    OPTIONS
        -DFFI_CONFIG_FILE=${CMAKE_CURRENT_LIST_DIR}/fficonfig.h
    OPTIONS_DEBUG
        -DFFI_SKIP_HEADERS=ON
)

vcpkg_install_cmake()
vcpkg_copy_pdbs()

if(VCPKG_LIBRARY_LINKAGE STREQUAL "static")
    vcpkg_apply_patches(
        SOURCE_PATH ${CURRENT_PACKAGES_DIR}/include
        PATCHES
            ${CMAKE_CURRENT_LIST_DIR}/auto-define-static-macro.patch
    )
endif()

file(COPY ${SOURCE_PATH}/LICENSE DESTINATION ${CURRENT_PACKAGES_DIR}/share/libffi)
file(RENAME ${CURRENT_PACKAGES_DIR}/share/libffi/LICENSE ${CURRENT_PACKAGES_DIR}/share/libffi/copyright)
