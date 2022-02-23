x_vcpkg_find_fortran(FORTRAN_CMAKE)
message(STATUS "VCPKG_USE_INTERNAL_Fortran:${VCPKG_USE_INTERNAL_Fortran}")
if(VCPKG_USE_INTERNAL_Fortran)
    foreach(_ver IN ITEMS 21 20 19)
        if(DEFINED ENV{IFORT_COMPILER${_ver}})
            cmake_path(CONVERT "$ENV{IFORT_COMPILER${_ver}}" TO_CMAKE_PATH_LIST IFORT_COMPILER_ROOT)
            break()
        endif()
    endforeach()
    message(STATUS "IFORT_COMPILER_ROOT:${IFORT_COMPILER_ROOT}" )
    message(STATUS "ENV{ONEAPI_ROOT}:$ENV{ONEAPI_ROOT}" )
    if(VCPKG_TARGET_ARCHITECTURE STREQUAL "x86")
        set(subpath "ia32_win")
    elseif(VCPKG_TARGET_ARCHITECTURE STREQUAL "x64")
        set(subpath "intel64_win")
    endif()

    if(VCPKG_LIBRARY_LINKAGE STREQUAL "static")
        set(IFORT_BASEPATH_LIBS "${IFORT_COMPILER_ROOT}/compiler/lib/${subpath}/")
        file(COPY "${IFORT_BASEPATH_LIBS}" DESTINATION "${CURRENT_PACKAGES_DIR}/share/ifort/")
    endif()
    if(VCPKG_LIBRARY_LINKAGE STREQUAL "dynamic")
        set(IFORT_BASEPATH_DLLS "${IFORT_COMPILER_ROOT}/redist/${subpath}/compiler/")
        set(IFORT_DLLS 
            libifportmd.dll
            libirngmd.dll
            svml_dispmd.dll
            libiomp5md.dll
            libiompstubs5md.dll
        )
        set(IFORT_DLLS_DEBUG
            libifcoremdd.dll
            libmmdd.dll
        )
        set(IFORT_DLLS_RELEASE
            libifcoremd.dll
            libmmd.dll
        )
        list(TRANSFORM IFORT_DLLS PREPEND "${IFORT_BASEPATH_DLLS}")
        list(TRANSFORM IFORT_DLLS_DEBUG PREPEND "${IFORT_BASEPATH_DLLS}")
        list(TRANSFORM IFORT_DLLS_RELEASE PREPEND "${IFORT_BASEPATH_DLLS}")

        file(MAKE_DIRECTORY "${CURRENT_PACKAGES_DIR}/bin" "${CURRENT_PACKAGES_DIR}/debug/bin")
        file(COPY ${IFORT_DLLS} ${IFORT_DLLS_RELEASE} DESTINATION "${CURRENT_PACKAGES_DIR}/bin")
        file(COPY ${IFORT_DLLS} ${IFORT_DLLS_DEBUG} DESTINATION "${CURRENT_PACKAGES_DIR}/debug/bin")
    endif()
    file(INSTALL "${IFORT_COMPILER_ROOT}/../../../licensing/latest/third-party-programs.txt" DESTINATION "${CURRENT_PACKAGES_DIR}/share/${PORT}" RENAME copyright) # ONEAPI_ROOT; please check if this is the correct license
    set(VCPKG_POLICY_DLLS_WITHOUT_LIBS enabled) # libs are at share/ifort and reflect how they are installed by the compiler instead of splitting them. 
    set(VCPKG_POLICY_EMPTY_INCLUDE_FOLDER enabled)
else()
    set(VCPKG_POLICY_EMPTY_PACKAGE enabled)
endif()