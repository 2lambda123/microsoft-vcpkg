vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO MiSo1289/asiochan
    REF 837d7eb78ca9796af800ca3cd91ce0a8fe297785
    SHA512 58e1e3291dc980ed59b0bc1fdcaa35db007e0044f4cbd352917caefa2d30b0c76a3db180091c1895867a3d026ce69f3a82b33dde3970cba5bef596620a2b20f8
    HEAD_REF master
)

file(GLOB_RECURSE HEADERS LIST_DIRECTORIES false "${SOURCE_PATH}/include/*")
foreach(ITEM ${HEADERS})
    get_filename_component(DIR "${ITEM}" DIRECTORY)
    file(RELATIVE_PATH TARGET_DIR "${SOURCE_PATH}/include" "${DIR}")
    file(INSTALL "${ITEM}" DESTINATION "${CURRENT_PACKAGES_DIR}/include/${TARGET_DIR}" )
endforeach()

file(INSTALL "${CMAKE_CURRENT_LIST_DIR}/usage" DESTINATION "${CURRENT_PACKAGES_DIR}/share/${PORT}")
file(INSTALL
    "${SOURCE_PATH}/LICENSE"
    DESTINATION "${CURRENT_PACKAGES_DIR}/share/${PORT}"
    RENAME copyright
)