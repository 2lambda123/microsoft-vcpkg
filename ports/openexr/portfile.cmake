if (VCPKG_CMAKE_SYSTEM_NAME STREQUAL "WindowsStore")
  message(FATAL_ERROR "UWP build not supported")
endif()

vcpkg_from_github(
  OUT_SOURCE_PATH SOURCE_PATH
  REPO openexr/openexr
  REF 918b8f543e81b5a1e1aca494ab7352ca280afc9e
  SHA512 7c4a22779718cb1a8962d53d0817a0b3cba90fc9ad4c6469e845bdfbf9ae8be8e43905ad8672955838976caeffd7dabcc6ea9c1f00babef0d5dfc8b5e058cce9
  HEAD_REF master
  PATCHES
    0001-remove_find_package_macro.patch
    0002-fixup_cmake_exports_path.patch
)

vcpkg_configure_cmake(SOURCE_PATH ${SOURCE_PATH}
  PREFER_NINJA
  OPTIONS
    -DCMAKE_DEBUG_POSTFIX=_d
    -DPYILMBASE_ENABLE=FALSE
)

vcpkg_install_cmake()

vcpkg_fixup_cmake_targets(CONFIG_PATH share/ilmbase TARGET_PATH share/ilmbase)
vcpkg_fixup_cmake_targets()
vcpkg_fixup_pkgconfig()

file(REMOVE ${CURRENT_PACKAGES_DIR}/debug/bin/exrenvmap${VCPKG_HOST_EXECUTABLE_SUFFIX})
file(REMOVE ${CURRENT_PACKAGES_DIR}/debug/bin/exrheader${VCPKG_HOST_EXECUTABLE_SUFFIX})
file(REMOVE ${CURRENT_PACKAGES_DIR}/debug/bin/exrmakepreview${VCPKG_HOST_EXECUTABLE_SUFFIX})
file(REMOVE ${CURRENT_PACKAGES_DIR}/debug/bin/exrmaketiled${VCPKG_HOST_EXECUTABLE_SUFFIX})
file(REMOVE ${CURRENT_PACKAGES_DIR}/debug/bin/exrmultipart${VCPKG_HOST_EXECUTABLE_SUFFIX})
file(REMOVE ${CURRENT_PACKAGES_DIR}/debug/bin/exrmultiview${VCPKG_HOST_EXECUTABLE_SUFFIX})
file(REMOVE ${CURRENT_PACKAGES_DIR}/debug/bin/exrstdattr${VCPKG_HOST_EXECUTABLE_SUFFIX})
file(REMOVE ${CURRENT_PACKAGES_DIR}/debug/bin/exr2aces${VCPKG_HOST_EXECUTABLE_SUFFIX})

file(MAKE_DIRECTORY ${CURRENT_PACKAGES_DIR}/tools/openexr/)
file(RENAME ${CURRENT_PACKAGES_DIR}/bin/exrenvmap${VCPKG_HOST_EXECUTABLE_SUFFIX} ${CURRENT_PACKAGES_DIR}/tools/openexr/exrenvmap${VCPKG_HOST_EXECUTABLE_SUFFIX})
file(RENAME ${CURRENT_PACKAGES_DIR}/bin/exrheader${VCPKG_HOST_EXECUTABLE_SUFFIX} ${CURRENT_PACKAGES_DIR}/tools/openexr/exrheader${VCPKG_HOST_EXECUTABLE_SUFFIX})
file(RENAME ${CURRENT_PACKAGES_DIR}/bin/exrmakepreview${VCPKG_HOST_EXECUTABLE_SUFFIX} ${CURRENT_PACKAGES_DIR}/tools/openexr/exrmakepreview${VCPKG_HOST_EXECUTABLE_SUFFIX})
file(RENAME ${CURRENT_PACKAGES_DIR}/bin/exrmaketiled${VCPKG_HOST_EXECUTABLE_SUFFIX} ${CURRENT_PACKAGES_DIR}/tools/openexr/exrmaketiled${VCPKG_HOST_EXECUTABLE_SUFFIX})
file(RENAME ${CURRENT_PACKAGES_DIR}/bin/exrmultipart${VCPKG_HOST_EXECUTABLE_SUFFIX} ${CURRENT_PACKAGES_DIR}/tools/openexr/exrmultipart${VCPKG_HOST_EXECUTABLE_SUFFIX})
file(RENAME ${CURRENT_PACKAGES_DIR}/bin/exrmultiview${VCPKG_HOST_EXECUTABLE_SUFFIX} ${CURRENT_PACKAGES_DIR}/tools/openexr/exrmultiview${VCPKG_HOST_EXECUTABLE_SUFFIX})
file(RENAME ${CURRENT_PACKAGES_DIR}/bin/exrstdattr${VCPKG_HOST_EXECUTABLE_SUFFIX} ${CURRENT_PACKAGES_DIR}/tools/openexr/exrstdattr${VCPKG_HOST_EXECUTABLE_SUFFIX})
file(RENAME ${CURRENT_PACKAGES_DIR}/bin/exr2aces${VCPKG_HOST_EXECUTABLE_SUFFIX} ${CURRENT_PACKAGES_DIR}/tools/openexr/exr2aces${VCPKG_HOST_EXECUTABLE_SUFFIX})
vcpkg_copy_tool_dependencies(${CURRENT_PACKAGES_DIR}/tools/openexr)

vcpkg_copy_pdbs()

if (VCPKG_CMAKE_SYSTEM_NAME OR VCPKG_LIBRARY_LINKAGE STREQUAL static)
  file(REMOVE_RECURSE ${CURRENT_PACKAGES_DIR}/bin ${CURRENT_PACKAGES_DIR}/debug/bin)
endif()

file(REMOVE_RECURSE ${CURRENT_PACKAGES_DIR}/debug/include)
file(REMOVE_RECURSE ${CURRENT_PACKAGES_DIR}/debug/share)

file(INSTALL ${CMAKE_CURRENT_LIST_DIR}/vcpkg-cmake-wrapper.cmake DESTINATION ${CURRENT_PACKAGES_DIR}/share/${PORT})
file(INSTALL ${SOURCE_PATH}/LICENSE.md DESTINATION ${CURRENT_PACKAGES_DIR}/share/${PORT} RENAME copyright)
