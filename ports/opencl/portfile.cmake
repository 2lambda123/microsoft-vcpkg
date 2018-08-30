include(vcpkg_common_functions)

# OpenCL C headers
vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO KhronosGroup/OpenCL-Headers
    REF a749dc6b85b3dcb57a54b17fcbf279c4f7198648
    SHA512 5909a85f96477d731059528303435f06255e98ed8df9d4cd2b62c744b5fe41408c69c0d4068421a2813eb9ad9d70d7f1bace9ebf0db19cc09e71bb8066127c5f
    HEAD_REF master
)

file(INSTALL
        "${SOURCE_PATH}/CL"
    DESTINATION
        ${CURRENT_PACKAGES_DIR}/include
)

# OpenCL C++ headers
vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO KhronosGroup/OpenCL-CLHPP
    REF bbccc50adcd667d4f7c58960b586bdc60c13f7f0
    SHA512 2909fe2b979b52724ef8d285180d8bfd30bdd56cb79da4effc9e03b576ec7edb5497c99a9fa30541fe63037c84ddef21d4a73e7927f3813baab2a2afeecd55ab
    HEAD_REF master
)

vcpkg_find_acquire_program(PYTHON3)

vcpkg_execute_required_process(
    COMMAND "${PYTHON3}" "${SOURCE_PATH}/gen_cl_hpp.py"
        -i ${SOURCE_PATH}/input_cl.hpp
        -o ${CURRENT_PACKAGES_DIR}/include/CL/cl.hpp
    WORKING_DIRECTORY ${SOURCE_PATH}
    LOGNAME generate_clhpp-${TARGET_TRIPLET}
)

vcpkg_execute_required_process(
    COMMAND "${PYTHON3}" "${SOURCE_PATH}/gen_cl_hpp.py"
        -i ${SOURCE_PATH}/input_cl2.hpp
        -o ${CURRENT_PACKAGES_DIR}/include/CL/cl2.hpp
    WORKING_DIRECTORY ${SOURCE_PATH}
    LOGNAME generate_cl2hpp-${TARGET_TRIPLET}
)
message(STATUS "Generating OpenCL C++ headers done")

# OpenCL ICD loader
vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO KhronosGroup/OpenCL-ICD-Loader
    REF 26a38983cbe5824fd5be03eab8d037758fc44360
    SHA512 3029f758ff0c39b57aa10d881af68e73532fd179c54063ed1d4529b7d6e27a5219e3c24b7fb5598d790ebcdc2441e00001a963671dc90fef2fc377c76d724f54
    HEAD_REF master
)

if(VCPKG_LIBRARY_LINKAGE STREQUAL "static")
    message(STATUS "Building the ICD loader as a static library is not supported. Building as DLLs instead.")
    set(VCPKG_LIBRARY_LINKAGE "dynamic")
endif()

vcpkg_configure_cmake(
    SOURCE_PATH ${SOURCE_PATH}
    PREFER_NINJA
    OPTIONS
        -DOPENCL_INCLUDE_DIRS=${CURRENT_PACKAGES_DIR}/include
)

vcpkg_build_cmake(TARGET OpenCL)

file(INSTALL
        "${CURRENT_BUILDTREES_DIR}/${TARGET_TRIPLET}-rel/OpenCL.lib"
    DESTINATION
        ${CURRENT_PACKAGES_DIR}/lib
)

file(INSTALL
        "${CURRENT_BUILDTREES_DIR}/${TARGET_TRIPLET}-dbg/OpenCL.lib"
    DESTINATION
        ${CURRENT_PACKAGES_DIR}/debug/lib
)

file(INSTALL
        "${SOURCE_PATH}/LICENSE.txt"
    DESTINATION
        ${CURRENT_PACKAGES_DIR}/share/${PORT}/copyright
)
file(COPY
        ${CMAKE_CURRENT_LIST_DIR}/usage
    DESTINATION
        ${CURRENT_PACKAGES_DIR}/share/${PORT}
)
