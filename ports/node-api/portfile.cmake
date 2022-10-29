# NodeJS has native modules API called node-api.
# This port uses cmake-js to download and build node-api for you.
# NPM is required to run cmake-js.

# Nor NPM output nor cmake-js output is left after portfile.cmake execution like npm packages or any other files.
# ${DOWNLOADS} and ${NODEJS_BIN_DIR} folders are used in process, but they are cleaned at the end.

# As a normal port, this port leaves some includes and libraries in ${CURRENT_PACKAGES_DIR}.
# So it doesn't break binary caching or any other vcpkg features.

set(base_path "${CURRENT_HOST_INSTALLED_DIR}/tools/node")
find_program(NODEJS NAMES node PATHS "${base_path}" "${base_path}/bin" NO_DEFAULT_PATHS)

if(NOT NODEJS)
  message(FATAL_ERROR "node not found in '${CURRENT_HOST_INSTALLED_DIR}/tools/node'")
endif()

if(VCPKG_HOST_IS_WINDOWS)
  set(NODEJS_BIN_DIR "${CURRENT_HOST_INSTALLED_DIR}/tools/node")
  set(NODEJS_DIR "${CURRENT_HOST_INSTALLED_DIR}/tools/node")
else()
  set(NODEJS_BIN_DIR "${CURRENT_HOST_INSTALLED_DIR}/tools/node/bin")
  set(NODEJS_DIR "${CURRENT_HOST_INSTALLED_DIR}/tools/node")
endif()

vcpkg_add_to_path(PREPEND "${NODEJS_BIN_DIR}")

if(VCPKG_HOST_IS_WINDOWS)
  set(npm_command "${NODEJS_BIN_DIR}/npm.cmd")
else()
  set(npm_command "${NODEJS_BIN_DIR}/npm")
endif()

file(REMOVE_RECURSE "${DOWNLOADS}/tmp-cmakejs-output")
file(REMOVE_RECURSE "${DOWNLOADS}/tmp-cmakejs-home")
file(MAKE_DIRECTORY "${DOWNLOADS}/tmp-cmakejs-output")
file(MAKE_DIRECTORY "${DOWNLOADS}/tmp-cmakejs-home")

# Clone from GitHub instead of `npm install cmake-js`

set(node_modules_download_dir "${NODEJS_BIN_DIR}/node_modules")

vcpkg_from_github(
  OUT_SOURCE_PATH CMAKE_JS_SOURCE_PATH
  REPO cmake-js/cmake-js
  REF v7.0.0 
  SHA512 8fc38282e0a5dd6c02441130a16adef267a3f40eb2d70855befaa14f57d0fb1fd56ed5cd3a5057ea3350c0724986837ac7374a7f6786f75c55b638e34e9d48c9
  HEAD_REF master
)
file(INSTALL "${CMAKE_JS_SOURCE_PATH}" DESTINATION "${node_modules_download_dir}" RENAME "cmake-js")

# Prevent pollution of user home directory
file(READ "${NODEJS_BIN_DIR}/node_modules/cmake-js/lib/environment.js" environment_js)
string(REPLACE "process.env[(os.platform() === \"win32\") ? \"USERPROFILE\" : \"HOME\"]" "\"${DOWNLOADS}/tmp-cmakejs-home\"" environment_js "${environment_js}")
file(WRITE "${NODEJS_BIN_DIR}/node_modules/cmake-js/lib/environment.js" "${environment_js}")

if(VCPKG_TARGET_ARCHITECTURE STREQUAL "x64")
  set(cmake_js_arch "x64")
elseif(VCPKG_TARGET_ARCHITECTURE STREQUAL "x86")
  set(cmake_js_arch "ia32")
elseif(VCPKG_TARGET_ARCHITECTURE STREQUAL "arm64")
  set(cmake_js_arch "arm64")
elseif(VCPKG_TARGET_ARCHITECTURE STREQUAL "arm")
  set(cmake_js_arch "arm")
else()
  message(FATAL_ERROR "Unsupported architecture: ${VCPKG_TARGET_ARCHITECTURE}")
endif()

file(COPY "${CMAKE_CURRENT_LIST_DIR}/package.json" DESTINATION "${NODEJS_BIN_DIR}")
file(COPY "${CMAKE_CURRENT_LIST_DIR}/cmake-js-fetch" DESTINATION "${NODEJS_BIN_DIR}")

set(npm_args
  # npm arguments:
  --prefix "${NODEJS_BIN_DIR}"
  run cmake-js-fetch
  --scripts-prepend-node-path

  # cmake-js arguments:
  -- --out "${DOWNLOADS}/tmp-cmakejs-output" --arch "${cmake_js_arch}" --cmake-path "${CMAKE_COMMAND}"
)
execute_process(COMMAND "${npm_command}" ${npm_args}
  WORKING_DIRECTORY ${CMAKE_CURRENT_LIST_DIR}
  RESULT_VARIABLE npm_result
  OUTPUT_VARIABLE npm_output
)

if(NOT "${npm_result}" STREQUAL "0")
  message(FATAL_ERROR "${npm_command} ${npm_args} exited with ${npm_result}:\n${npm_output}")
endif()

include("${DOWNLOADS}/tmp-cmakejs-output/node.cmake")

file(COPY "${CMAKE_JS_INC}" DESTINATION "${CURRENT_PACKAGES_DIR}/include")

# Emptyness of the variables depends on the platform
if(CMAKE_JS_LIB)
  file(COPY "${CMAKE_JS_LIB}" DESTINATION "${CURRENT_PACKAGES_DIR}/lib")
  file(COPY "${CMAKE_JS_LIB}" DESTINATION "${CURRENT_PACKAGES_DIR}/debug/lib")
endif()

if(CMAKE_JS_SRC)
  file(COPY "${CMAKE_JS_SRC}" DESTINATION "${CURRENT_PACKAGES_DIR}/share/${PORT}")
endif()

# Handle copyright
file(INSTALL "${NODEJS_DIR}/LICENSE" DESTINATION "${CURRENT_PACKAGES_DIR}/share/${PORT}" RENAME copyright)

# Copy ./unofficial-node-api-config.cmake to ${CURRENT_PACKAGES_DIR}/share/node-api
file(COPY "${CMAKE_CURRENT_LIST_DIR}/unofficial-node-api-config.cmake" DESTINATION "${CURRENT_PACKAGES_DIR}/share/unofficial-${PORT}")

# Vcpkg remove doesn't remove cmake-js, so we need to remove it manually right now
file(GLOB cmakejs_files "${NODEJS_BIN_DIR}/cmake-js*")
file(REMOVE ${cmakejs_files})
file(REMOVE_RECURSE "${NODEJS_BIN_DIR}/node_modules/cmake-js")
file(REMOVE_RECURSE "${NODEJS_BIN_DIR}/cmake-js-fetch")
file(REMOVE "${NODEJS_BIN_DIR}/package.json")