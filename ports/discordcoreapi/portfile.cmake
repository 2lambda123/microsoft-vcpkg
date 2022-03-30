vcpkg_from_github(
	OUT_SOURCE_PATH SOURCE_PATH
	REPO RealTimeChris/DiscordCoreAPI
	REF 2278dcf6cbfa6bb6c7c8a4c37ca7ce5ec09b7630
	SHA512 9555cf67a497d908c3e047006edbe64aa81548a1140f0c7f700fd2cafe0bc53d9060de0d5b418f2d4a58c88110434c5fe57af509795ba7bbdd93d20ce26643ce
	HEAD_REF main
)

vcpkg_cmake_configure(
	SOURCE_PATH "${SOURCE_PATH}"
	MAYBE_UNUSED_VARIABLES
	"${_VCPKG_INSTALLED_DIR}"
)

vcpkg_cmake_install()

file(REMOVE_RECURSE "${CURRENT_PACKAGES_DIR}/debug/bin" "${CURRENT_PACKAGES_DIR}/bin")
file(REMOVE_RECURSE "${CURRENT_PACKAGES_DIR}/debug/include")

file(
	INSTALL "${SOURCE_PATH}/License"
	DESTINATION "${CURRENT_PACKAGES_DIR}/share/${PORT}"
	RENAME copyright
)
