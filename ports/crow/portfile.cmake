vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO CrowCpp/crow
    REF 696fbb104369ee948b00274a5e7e677c405f460e #0.2
    SHA512 9d925c229e6380555293909b941465b5419e6311e56d64da28e46bb4cdf9bdffd4adbbb37314a88f7abf4d2337e5baf26a5b107fedee4895e057eba1648c8b9c
    HEAD_REF master
)

file(INSTALL ${SOURCE_PATH}/include/ DESTINATION ${CURRENT_PACKAGES_DIR}/include)
file(INSTALL ${SOURCE_PATH}/LICENSE DESTINATION ${CURRENT_PACKAGES_DIR}/share/${PORT} RENAME copyright)
