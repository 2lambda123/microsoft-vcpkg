message(STATUS "Using VCPKG FindLAPACK from package 'lapack-reference'")
set(LAPACK_PREV_MODULE_PATH "${CMAKE_MODULE_PATH}")
list(APPEND CMAKE_MODULE_PATH "${CMAKE_CURRENT_LIST_DIR}")

list(REMOVE_ITEM ARGS "NO_MODULE")
list(REMOVE_ITEM ARGS "CONFIG")
list(REMOVE_ITEM ARGS "MODULE")

if(@USE_OPTIMIZED_BLAS@)
    _find_package(BLAS)
endif()

set(BLA_VENDOR @BLA_VENDOR@)
set(BLA_STATIC @BLA_STATIC@)
_find_package(${ARGS})
unset(BLA_VENDOR)
unset(BLA_STATIC)

set(CMAKE_MODULE_PATH "${LAPACK_PREV_MODULE_PATH}")
