vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO realtimechris/jsonifier
    REF "v${VERSION}"    
    SHA512 6e4e66d417970c64d11040c9f56a16e47ffe3c606fe9f92f7e2164bb5fb16f7a23b459b2e86d14c3a5920a2d13210c9590f3e0ca393ed4eeb19c8f2d89d8e355
    HEAD_REF main
)

set(VCPKG_BUILD_TYPE release) # header-only

vcpkg_cmake_configure(
    SOURCE_PATH "${SOURCE_PATH}"
)

vcpkg_cmake_install()

vcpkg_install_copyright(FILE_LIST "${SOURCE_PATH}/License.md")
