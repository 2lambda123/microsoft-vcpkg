vcpkg_check_linkage(ONLY_DYNAMIC_LIBRARY)

vcpkg_from_github(
    OUT_SOURCE_PATH QUIC_SOURCE_PATH
    REPO microsoft/msquic
    REF "v${VERSION}"
    SHA512 6590a18ec698cffc1c9639a2bd25f38d8786f46395dc217ddcb60b08ccf22da759df9bc4833fc621b97cf5418898f8b5125a409bac05d9bec8560722e7935c03
    HEAD_REF master
    PATCHES
        fix-warnings.patch  # Remove /WX, -Werror
        fix-platform.patch  # Make OpenSSL build use VCPKG_TARGET_ARCHITECTURE
)

vcpkg_from_github(
    OUT_SOURCE_PATH OPENSSL_SOURCE_PATH
    REPO quictls/openssl
    REF a6e9d76db343605dae9b59d71d2811b195ae7434
    SHA512 23510a11203b96476c194a1987c7d4e758375adef0f6dfe319cd8ec4b8dd9b12ea64c4099cf3ba35722b992dad75afb1cfc5126489a5fa59f5ee4d46bdfbeaf6
    HEAD_REF OpenSSL_1_1_1k+quic
)

file(REMOVE_RECURSE "${QUIC_SOURCE_PATH}/submodules/openssl")
file(RENAME "${OPENSSL_SOURCE_PATH}" "${QUIC_SOURCE_PATH}/submodules/openssl")

if(VCPKG_TARGET_IS_WINDOWS)
    LIST(APPEND QUIC_TLS "schannel")
else()
    LIST(APPEND QUIC_TLS "openssl")
    
    vcpkg_find_acquire_program(PERL)
    get_filename_component(PERL_EXE_PATH ${PERL} DIRECTORY)
    vcpkg_add_to_path(${PERL_EXE_PATH})
    
    vcpkg_find_acquire_program(NASM)
    get_filename_component(NASM_EXE_PATH ${NASM} DIRECTORY)
    vcpkg_add_to_path(PREPEND ${NASM_EXE_PATH})

endif()


vcpkg_check_features(OUT_FEATURE_OPTIONS FEATURE_OPTIONS
    FEATURES
        tools QUIC_BUILD_TOOLS
)

vcpkg_cmake_configure(
    SOURCE_PATH "${QUIC_SOURCE_PATH}"
    DISABLE_PARALLEL_CONFIGURE
    OPTIONS
        ${FEATURE_OPTIONS}
        -DQUIC_SOURCE_LINK=OFF
        -DQUIC_TLS=${QUIC_TLS}
        -DQUIC_USE_SYSTEM_LIBCRYPTO=OFF
        -DQUIC_BUILD_SHARED=ON
        -DQUIC_UWP_BUILD=${VCPKG_TARGET_IS_UWP}
)

if(NOT VCPKG_HOST_IS_WINDOWS)
    find_program(MAKE make)
    get_filename_component(MAKE_EXE_PATH ${MAKE} DIRECTORY)
    vcpkg_add_to_path(PREPEND ${MAKE_EXE_PATH})
endif()



#vcpkg_cmake_build(TARGET OpenSSL_Build) # separate build log for quictls/openssl
vcpkg_cmake_install()
vcpkg_cmake_config_fixup(PACKAGE_NAME msquic CONFIG_PATH "share/msquic")

if("tools" IN_LIST FEATURES)
    vcpkg_copy_tools(TOOL_NAMES quicattack quicinterop quicinteropserver quicipclient quicipserver
                                quicpcp quicping quicpost quicreach quicsample spinquic
        AUTO_CLEAN
    )
endif()

vcpkg_install_copyright(FILE_LIST "${QUIC_SOURCE_PATH}/LICENSE") 

if(EXISTS "${CURRENT_PACKAGES_DIR}/lib/msquic.dll")
    file(MAKE_DIRECTORY "${CURRENT_PACKAGES_DIR}/bin")
    file(RENAME "${CURRENT_PACKAGES_DIR}/lib/msquic.dll" "${CURRENT_PACKAGES_DIR}/bin/msquic.dll") 
endif()

if(EXISTS "${CURRENT_PACKAGES_DIR}/debug/lib/msquic.dll")
    file(MAKE_DIRECTORY "${CURRENT_PACKAGES_DIR}/debug/bin")
    file(RENAME "${CURRENT_PACKAGES_DIR}/debug/lib/msquic.dll" "${CURRENT_PACKAGES_DIR}/debug/bin/msquic.dll") 
endif()

file(REMOVE_RECURSE "${CURRENT_PACKAGES_DIR}/debug/share"
                    "${CURRENT_PACKAGES_DIR}/debug/include"
)

