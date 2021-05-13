# see https://github.com/boostorg/json/issues/556 fore more details
file(READ "${SOURCE_PATH}/build/Jamfile" _contents)
string(REPLACE "import ../../config/checks/config" "import config/checks/config" _contents "${_contents}")
string(REPLACE "\n      <library>/boost//container/<warnings-as-errors>off" "" _contents "${_contents}")
file(WRITE "${SOURCE_PATH}/build/Jamfile" "${_contents}")

file(READ "${SOURCE_PATH}/Jamfile" _contents)
string(REPLACE "import ../config/checks/config" "import build/config/checks/config" _contents "${_contents}")
file(WRITE "${SOURCE_PATH}/Jamfile" "${_contents}")

file(COPY "${CURRENT_INSTALLED_DIR}/share/boost-config/checks" DESTINATION "${SOURCE_PATH}/build/config")
