vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO zeromq/azmq
    REF 7da2fd0a1b2bd4e6f50ccd17d54579e6084ef1f7 # commit on 2021-11-20
    SHA512 3f6b07fab9345c7506a46d7418eb672e1ee28a72bb02914ee1f945b3c41090d94722079469359664232e9688beac4e354e49d99711fc5b0bd1d6f7936ed62a3c
    HEAD_REF master
)

file(COPY ${SOURCE_PATH}/azmq DESTINATION ${CURRENT_PACKAGES_DIR}/include/)

file(INSTALL
    ${SOURCE_PATH}/LICENSE-BOOST_1_0
    DESTINATION ${CURRENT_PACKAGES_DIR}/share/${PORT} RENAME copyright)
