set(VCPKG_POLICY_EMPTY_PACKAGE enabled)

vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO corrosion-rs/corrosion
    REF "v${VERSION}"
    SHA512 274baca57f7d599b304b75a73067fae9eb488eec10925fade7e195d494a192760b116a3bdf289e0cb7c291b29684909d5fd1c9404c6d37203c883cd511849bbb 
    HEAD_REF master
)

find_program(CARGO cargo PATHS "$ENV{HOME}/.cargo/bin/")
if (CARGO STREQUAL "CARGO-NOTFOUND")
    message("Could not find cargo, trying to install via https://rustup.rs/.")
    execute_process(COMMAND bash "-c" "curl -sSf https://sh.rustup.rs | sh -s -- -y")
endif()

include(CMakePackageConfigHelpers)

#configure_package_config_file(
#	${SOURCE_PATH}/cmake/CorrosionConfig.cmake.in ${CURRENT_PACKAGES_DIR}/share/${PORT}/CorrosionConfig.cmake
#    INSTALL_DESTINATION
#        "${CURRENT_PACKAGES_DIR}/share/${PORT}"
#)

write_basic_package_version_file(
    "${CURRENT_PACKAGES_DIR}/share/${PORT}/CorrosionConfigVersion.cmake"
    VERSION v${VERSION}
    COMPATIBILITY
        SameMinorVersion # TODO: Should be SameMajorVersion when 1.0 is released
    ARCH_INDEPENDENT
)

file(INSTALL
        ${SOURCE_PATH}/cmake/Corrosion.cmake
     DESTINATION
        ${CURRENT_PACKAGES_DIR/share/${PORT}
     RENAME
        CorrosionConfig.cmake
)

file(INSTALL
        ${SOURCE_PATH}/cmake/CorrosionGenerator.cmake
        ${SOURCE_PATH}/cmake/FindRust.cmake
    DESTINATION
        "${CURRENT_PACKAGES_DIR}/share/${PORT}"
)

# These CMake scripts are needed both for the install and as a subdirectory
file(INSTALL
        ${SOURCE_PATH}/cmake/Corrosion.cmake
        ${SOURCE_PATH}/cmake/CorrosionGenerator.cmake
        ${SOURCE_PATH}/cmake/FindRust.cmake
    DESTINATION
	"${CURRENT_PACKAGES_DIR}/share/${PORT}/cmake"
)

vcpkg_install_copyright(FILE_LIST "${SOURCE_PATH}/LICENSE")
file(COPY "${CMAKE_CURRENT_LIST_DIR}/usage" DESTINATION "${CURRENT_PACKAGES_DIR}/share/${PORT}")

