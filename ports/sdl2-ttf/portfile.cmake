set(VERSION 2.20.0)

vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO  libsdl-org/SDL_ttf
    REF f5e4828ffc9d3a84f00011fede4446aecb4a685f #v2.20.0
    SHA512 c0d2d6107e5427d9c1353e14cb4b0c3957d28391cfc772f1f972fe3aa8ba9e9dfdfcb64acd317a7836d46b3a50da9597b19a832f0baf5198654acb7b31ab1e6b
    HEAD_REF main
    PATCHES
        fix-find_dependencies.patch
)

string(COMPARE EQUAL "${VCPKG_LIBRARY_LINKAGE}" "dynamic" BUILD_SHARED)

vcpkg_cmake_configure(
    SOURCE_PATH "${SOURCE_PATH}"
    OPTIONS
        -DSDL2TTF_SAMPLES=OFF
        -DBUILD_SHARED_LIBS=${BUILD_SHARED}
)

vcpkg_install_cmake()
vcpkg_copy_pdbs()
vcpkg_cmake_config_fixup(CONFIG_PATH cmake)

#Clean
file(REMOVE_RECURSE "${CURRENT_PACKAGES_DIR}/debug/include")
file(REMOVE_RECURSE "${CURRENT_PACKAGES_DIR}/debug/share")   

#Copyright
file(COPY "${SOURCE_PATH}/LICENSE.txt" DESTINATION "${CURRENT_PACKAGES_DIR}/share/sdl2-ttf/copyright")
