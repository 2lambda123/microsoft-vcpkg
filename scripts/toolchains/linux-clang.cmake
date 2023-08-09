if (NOT _VCPKG_LINUX_CLANG_TOOLCHAIN)
    set(_VCPKG_LINUX_CLANG_TOOLCHAIN 1)

    if (CMAKE_HOST_SYSTEM_NAME STREQUAL "Linux")
        set(CMAKE_CROSSCOMPILING OFF CACHE BOOL "")
    endif ()
    if (VCPKG_TARGET_ARCHITECTURE STREQUAL "x64")
        set(CMAKE_SYSTEM_PROCESSOR x86_64 CACHE STRING "")
    endif ()
    set(CMAKE_SYSTEM_NAME Linux CACHE STRING "")

    set(CMAKE_CXX_COMPILER "/usr/bin/clang++")
    set(CMAKE_C_COMPILER "/usr/bin/clang")
    
    get_property(_CMAKE_IN_TRY_COMPILE GLOBAL PROPERTY IN_TRY_COMPILE)
    if (NOT _CMAKE_IN_TRY_COMPILE)
        string(APPEND CMAKE_C_FLAGS_INIT " -stdlib=libc++ -fPIC ${VCPKG_C_FLAGS} ")
        string(APPEND CMAKE_CXX_FLAGS_INIT " -stdlib=libc++ -fPIC ${VCPKG_CXX_FLAGS} ")
        string(APPEND CMAKE_C_FLAGS_DEBUG_INIT " -stdlib=libc++ ${VCPKG_C_FLAGS_DEBUG} ")
        string(APPEND CMAKE_CXX_FLAGS_DEBUG_INIT " -stdlib=libc++ ${VCPKG_CXX_FLAGS_DEBUG} ")
        string(APPEND CMAKE_C_FLAGS_RELEASE_INIT " -stdlib=libc++ ${VCPKG_C_FLAGS_RELEASE} ")
        string(APPEND CMAKE_CXX_FLAGS_RELEASE_INIT " -stdlib=libc++ ${VCPKG_CXX_FLAGS_RELEASE} ")

        string(APPEND CMAKE_MODULE_LINKER_FLAGS_INIT " -lc++ -lc++abi ${VCPKG_LINKER_FLAGS} ")
        string(APPEND CMAKE_SHARED_LINKER_FLAGS_INIT " -lc++ -lc++abi ${VCPKG_LINKER_FLAGS} ")
        string(APPEND CMAKE_EXE_LINKER_FLAGS_INIT " -lc++ -lc++abi ${VCPKG_LINKER_FLAGS} ")
        string(APPEND CMAKE_MODULE_LINKER_FLAGS_DEBUG_INIT " -lc++ -lc++abi ${VCPKG_LINKER_FLAGS_DEBUG} ")
        string(APPEND CMAKE_SHARED_LINKER_FLAGS_DEBUG_INIT " -lc++ -lc++abi ${VCPKG_LINKER_FLAGS_DEBUG} ")
        string(APPEND CMAKE_EXE_LINKER_FLAGS_DEBUG_INIT " -lc++ -lc++abi ${VCPKG_LINKER_FLAGS_DEBUG} ")
        string(APPEND CMAKE_MODULE_LINKER_FLAGS_RELEASE_INIT " -lc++ -lc++abi ${VCPKG_LINKER_FLAGS_RELEASE} ")
        string(APPEND CMAKE_SHARED_LINKER_FLAGS_RELEASE_INIT " -lc++ -lc++abi ${VCPKG_LINKER_FLAGS_RELEASE} ")
        string(APPEND CMAKE_EXE_LINKER_FLAGS_RELEASE_INIT " -lc++ -lc++abi ${VCPKG_LINKER_FLAGS_RELEASE} ")
    endif (NOT _CMAKE_IN_TRY_COMPILE)
endif (NOT _VCPKG_LINUX_CLANG_TOOLCHAIN)
