include(vcpkg_common_functions)

set(PODOFO_VERSION 0.9.6)
vcpkg_download_distfile(ARCHIVE
    URLS "https://sourceforge.net/projects/podofo/files/podofo/${PODOFO_VERSION}/podofo-${PODOFO_VERSION}.tar.gz/download"
    FILENAME "podofo-${PODOFO_VERSION}.tar.gz"
    SHA512 35c1a457758768bdadc93632385f6b9214824fead279f1b85420443fb2135837cefca9ced476df0d47066f060e9150e12fcd40f60fa1606b177da433feb20130
)
vcpkg_extract_source_archive_ex(
    OUT_SOURCE_PATH SOURCE_PATH
    ARCHIVE ${ARCHIVE}
    REF ${PODOFO_VERSION}
    PATCHES 
        unique_ptr.patch
        002-HAVE_UNISTD_H.patch
        fix_dependencies.patch
)

set(PODOFO_NO_FONTMANAGER ON)
if("fontconfig" IN_LIST FEATURES)
  set(PODOFO_NO_FONTMANAGER OFF)
endif()

string(COMPARE EQUAL "${VCPKG_LIBRARY_LINKAGE}" "dynamic" PODOFO_BUILD_SHARED)
string(COMPARE EQUAL "${VCPKG_LIBRARY_LINKAGE}" "static" PODOFO_BUILD_STATIC)

set(IS_WIN32 OFF)
if(VCPKG_CMAKE_SYSTEM_NAME STREQUAL "WindowsStore" OR NOT VCPKG_CMAKE_SYSTEM_NAME)
    set(IS_WIN32 ON)
endif()

file(REMOVE ${SOURCE_PATH}/cmake/modules/FindOpenSSL.cmake)
file(REMOVE ${SOURCE_PATH}/cmake/modules/FindLIBCRYPTO.cmake)
file(REMOVE ${SOURCE_PATH}/cmake/modules/FindZLIB.cmake)
file(REMOVE ${SOURCE_PATH}/cmake/modules/FindLIBJPEG.cmake)

vcpkg_configure_cmake(
    SOURCE_PATH ${SOURCE_PATH}
    PREFER_NINJA
    OPTIONS
        -DPODOFO_BUILD_LIB_ONLY=1
        -DPODOFO_BUILD_SHARED=${PODOFO_BUILD_SHARED}
        -DPODOFO_BUILD_STATIC=${PODOFO_BUILD_STATIC}
        -DPODOFO_NO_FONTMANAGER=${PODOFO_NO_FONTMANAGER}
        -DCMAKE_DISABLE_FIND_PACKAGE_FONTCONFIG=${PODOFO_NO_FONTMANAGER}
        -DCMAKE_DISABLE_FIND_PACKAGE_LIBCRYPTO=${IS_WIN32}
        -DCMAKE_DISABLE_FIND_PACKAGE_LIBIDN=ON
        -DCMAKE_DISABLE_FIND_PACKAGE_CppUnit=ON
        -DCMAKE_DISABLE_FIND_PACKAGE_Boost=ON
)

vcpkg_install_cmake()
file(REMOVE_RECURSE ${CURRENT_PACKAGES_DIR}/debug/include)

# Handle copyright
file(COPY ${SOURCE_PATH}/COPYING DESTINATION ${CURRENT_PACKAGES_DIR}/share/podofo)
file(RENAME ${CURRENT_PACKAGES_DIR}/share/podofo/COPYING ${CURRENT_PACKAGES_DIR}/share/podofo/copyright)
