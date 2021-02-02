# Outcome is composed of other third party libraries:
#    Outcome
#      <= status-code
#      <= quickcpplib
#         <= byte-lite
#         <= gsl-lite
#         <= Optional
#
# byte-lite and gsl-lite are in vcpkg, but may not be versions
# known to be compatible with Outcome. It has occurred in the
# past that newer versions were severely broken with Outcome.
#
# One can fetch an 'all sources' tarball from
# https://github.com/ned14/outcome/releases which contains
# the exact copy of those third party libraries known to
# have passed Outcome's CI process.

message(WARNING [=[
Outcome depends on QuickCppLib which uses the vcpkg versions of gsl-lite and byte-lite, rather than the versions tested by QuickCppLib's and Outcome's CI. It is not guaranteed to work with other versions, with failures experienced in the past up-to-and-including runtime crashes. See the warning message from QuickCppLib for how you can pin the versions of those dependencies in your manifest file to those with which QuickCppLib was tested. Do not report issues to upstream without first pinning the versions as QuickCppLib was tested against.
]=])

vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO ned14/outcome
#    REF all_tests_passed_35454acdb1ff76accdf213ecf068760c370b6d62
    REF 6abb6bb68fa6aaf07b6392a855f3f16a53c7debe
    SHA512 614c78ac75ae36f4b09ed5e3067bd35934090667c25cae58d3d17ffa2cce5f40c7d80baaa6076d9343bf2092c109bf214eb1446a87c2f61c704ae7dc0594cde1
    HEAD_REF develop
    PATCHES
      outcome-prune-sources.patch
)

vcpkg_check_features(
    OUT_FEATURE_OPTIONS OUTCOME_FEATURE_OPTIONS
    FEATURES
      run-tests OUTCOME_ENABLE_DEPENDENCY_SMOKE_TEST
)

# Outcome needs a copy of QuickCppLib with which to bootstrap its cmake
file(COPY "${CURRENT_INSTALLED_DIR}/include/quickcpplib"
    DESTINATION "${SOURCE_PATH}/quickcpplib/repo/include/"
)
file(COPY "${CURRENT_INSTALLED_DIR}/share/ned14-internal-quickcpplib/"
    DESTINATION "${SOURCE_PATH}/quickcpplib/repo/"
)

# Outcome expects status-code to live inside its include directory
file(COPY "${CURRENT_INSTALLED_DIR}/include/status-code/"
    DESTINATION "${SOURCE_PATH}/include/outcome/experimental/status-code/include/"
)
file(COPY "${CURRENT_INSTALLED_DIR}/include/status-code/detail/"
    DESTINATION "${SOURCE_PATH}/include/outcome/experimental/status-code/include/detail/"
)


# Because outcome's deployed files are header-only, the debug build is not necessary
set(VCPKG_BUILD_TYPE release)

# Use Outcome's own build process, skipping examples and tests.
vcpkg_configure_cmake(
    SOURCE_PATH "${SOURCE_PATH}"
    PREFER_NINJA
    OPTIONS
        -DPROJECT_IS_DEPENDENCY=On
        -Dquickcpplib_FOUND=1
        "-DCMAKE_CXX_FLAGS=-I${CURRENT_INSTALLED_DIR}/include"
        -DOUTCOME_ENABLE_DEPENDENCY_SMOKE_TEST=ON  # Leave this always on to test everything compiles
        -DCMAKE_DISABLE_FIND_PACKAGE_Git=ON
)

if("-DOUTCOME_ENABLE_DEPENDENCY_SMOKE_TEST=ON" IN_LIST OUTCOME_FEATURE_OPTIONS)
    vcpkg_build_cmake(TARGET test)
endif()

vcpkg_install_cmake()

vcpkg_fixup_cmake_targets(CONFIG_PATH lib/cmake/outcome)

file(REMOVE_RECURSE "${CURRENT_PACKAGES_DIR}/lib")

file(INSTALL "${CURRENT_PORT_DIR}/usage" DESTINATION "${CURRENT_PACKAGES_DIR}/share/${PORT}")
file(INSTALL "${SOURCE_PATH}/Licence.txt" DESTINATION "${CURRENT_PACKAGES_DIR}/share/${PORT}" RENAME copyright)
