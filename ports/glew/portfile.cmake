include(vcpkg_common_functions)

set(SOURCE_PATH ${CURRENT_BUILDTREES_DIR}/src/glew/glew-2.1.0)

# Don't change to vcpkg_from_github! The github-auto-generated archives are missing some files.
# More info: https://github.com/nigels-com/glew/issues/31 and https://github.com/nigels-com/glew/issues/13
vcpkg_download_distfile(ARCHIVE_FILE
    URLS "https://github.com/nigels-com/glew/releases/download/glew-2.1.0/glew-2.1.0.tgz"
    FILENAME "glew-2.1.0.tgz"
    SHA512 9a9b4d81482ccaac4b476c34ed537585ae754a82ebb51c3efa16d953c25cc3931be46ed2e49e79c730cd8afc6a1b78c97d52cd714044a339c3bc29734cd4d2ab
)
vcpkg_extract_source_archive(${ARCHIVE_FILE} ${CURRENT_BUILDTREES_DIR}/src/glew)

vcpkg_apply_patches(
    SOURCE_PATH ${SOURCE_PATH}
	PATCHES fix-LNK2019.patch
)

vcpkg_configure_cmake(
    SOURCE_PATH ${SOURCE_PATH}/build/cmake
    DISABLE_PARALLEL_CONFIGURE
    OPTIONS
        -DBUILD_UTILS=OFF
    )

vcpkg_install_cmake()

vcpkg_fixup_cmake_targets(CONFIG_PATH "lib/cmake/glew")

set(_targets_cmake_files)
if(NOT DEFINED VCPKG_BUILD_TYPE OR VCPKG_BUILD_TYPE STREQUAL "debug")
    list(APPEND _targets_cmake_files "${CURRENT_PACKAGES_DIR}/share/glew/glew-targets-debug.cmake")
endif()
if(NOT DEFINED VCPKG_BUILD_TYPE OR VCPKG_BUILD_TYPE STREQUAL "release")
    list(APPEND _targets_cmake_files "${CURRENT_PACKAGES_DIR}/share/glew/glew-targets-release.cmake")
endif()

foreach(FILE ${_targets_cmake_files})
    file(READ ${FILE} _contents)
    string(REPLACE "libglew32" "glew32" _contents "${_contents}")
    file(WRITE ${FILE} "${_contents}")
endforeach()

if(EXISTS ${CURRENT_PACKAGES_DIR}/lib/libglew32.lib)
    file(RENAME ${CURRENT_PACKAGES_DIR}/lib/libglew32.lib ${CURRENT_PACKAGES_DIR}/lib/glew32.lib)
endif()
if(EXISTS ${CURRENT_PACKAGES_DIR}/debug/lib/libglew32d.lib)
    file(RENAME ${CURRENT_PACKAGES_DIR}/debug/lib/libglew32d.lib ${CURRENT_PACKAGES_DIR}/debug/lib/glew32d.lib)
endif()

if(VCPKG_LIBRARY_LINKAGE STREQUAL "static")
    file(REMOVE_RECURSE ${CURRENT_PACKAGES_DIR}/debug/bin)
    file(REMOVE_RECURSE ${CURRENT_PACKAGES_DIR}/bin)
    foreach(FILE ${CURRENT_PACKAGES_DIR}/include/GL/glew.h ${CURRENT_PACKAGES_DIR}/include/GL/wglew.h ${CURRENT_PACKAGES_DIR}/include/GL/glxew.h)
        file(READ ${FILE} _contents)
        string(REPLACE "#ifdef GLEW_STATIC" "#if 1" _contents "${_contents}")
        file(WRITE ${FILE} "${_contents}")
    endforeach()
endif()

vcpkg_copy_pdbs()

file(REMOVE_RECURSE ${CURRENT_PACKAGES_DIR}/debug/include)
file(REMOVE_RECURSE ${CURRENT_PACKAGES_DIR}/debug/share)

file(INSTALL ${SOURCE_PATH}/LICENSE.txt DESTINATION ${CURRENT_PACKAGES_DIR}/share/glew RENAME copyright)
file(COPY ${CMAKE_CURRENT_LIST_DIR}/usage DESTINATION ${CURRENT_PACKAGES_DIR}/share/${PORT})
