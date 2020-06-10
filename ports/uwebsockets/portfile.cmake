vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO uNetworking/uWebSockets
    REF 025415d1a0174cf581b481fd2b3f155241a1265b # v18.1.0
    SHA512 02888ebe3e678c9ba0d072543cb04041cc72881074a0feb05eaef3d9eb570c4b4cc4319d3b5ccdd3eca8bc93946aa0669edcbc1508fb03153251f3a1b629cfac
    HEAD_REF master
)

file(COPY ${SOURCE_PATH}/src  DESTINATION ${CURRENT_PACKAGES_DIR}/include)
file(RENAME ${CURRENT_PACKAGES_DIR}/include/src ${CURRENT_PACKAGES_DIR}/include/uwebsockets/)

file(INSTALL ${SOURCE_PATH}/LICENSE DESTINATION ${CURRENT_PACKAGES_DIR}/share/${PORT} RENAME copyright)
