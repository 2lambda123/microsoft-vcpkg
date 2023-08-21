vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO wolfssl/wolfssl
    REF v5.6.3-stable
    SHA512 7c3b5c06ade7826031db089d50ec45c36970555499b6be94d1939b3002369fc98e503418128c6b2e253df7e92f86a71647d37f2cd27d57ac201e5aba32b879dc
    HEAD_REF master
    PATCHES
      warning-and-include.patch
    )

if ("dtls" IN_LIST FEATURES)
    set(ENABLE_DTLS yes)
else()
    set(ENABLE_DTLS no)
endif()

set(CMAKE_C_FLAGS "-DWOLFSSL_ALT_CERT_CHAINS -DWOLFSSL_DES_ECB -DWOLFSSL_CUSTOM_OID -DHAVE_OID_ENCODING -DWOLFSSL_CERT_GEN -DWOLFSSL_ASN_TEMPLATE -DWOLFSSL_KEY_GEN -DHAVE_PKCS7 -DHAVE_AES_KEYWRAP -DWOLFSSL_AES_DIRECT -DHAVE_X963_KDF")
if ("secret-callback" IN_LIST FEATURES)
    set(CMAKE_C_FLAGS "${CMAKE_C_FLAGS} -DHAVE_SECRET_CALLBACK")
endif()

vcpkg_cmake_configure(
    SOURCE_PATH ${SOURCE_PATH}
    OPTIONS
      -DWOLFSSL_BUILD_OUT_OF_TREE=yes
      -DWOLFSSL_EXAMPLES=no
      -DWOLFSSL_CRYPT_TESTS=no
      -DWOLFSSL_OPENSSLEXTRA=yes
      -DWOLFSSL_TPM=yes
      -DWOLFSSL_TLSX=yes
      -DWOLFSSL_OCSP=yes
      -DWOLFSSL_OCSPSTAPLING=yes
      -DWOLFSSL_OCSPSTAPLING_V2=yes
      -DWOLFSSL_CRL=yes
      -DWOLFSSL_DES3=yes
      -DWOLFSSL_DTLS=${ENABLE_DTLS}
      -DCMAKE_C_FLAGS=${CMAKE_C_FLAGS}
    OPTIONS_DEBUG
      -DWOLFSSL_DEBUG=yes)

vcpkg_cmake_install()
vcpkg_copy_pdbs()

file(INSTALL "${SOURCE_PATH}/COPYING" DESTINATION "${CURRENT_PACKAGES_DIR}/share/${PORT}" RENAME copyright)

vcpkg_cmake_config_fixup(CONFIG_PATH lib/cmake/wolfssl)
vcpkg_fixup_pkgconfig()

file(REMOVE_RECURSE "${CURRENT_PACKAGES_DIR}/debug/include")
file(REMOVE_RECURSE "${CURRENT_PACKAGES_DIR}/debug/share")
