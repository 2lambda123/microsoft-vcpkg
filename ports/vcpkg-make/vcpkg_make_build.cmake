#[===[.md:
# vcpkg_make_build

Build a linux makefile project.

```cmake
vcpkg_make_build(
    [BUILD_TARGET <target>]
    [ADD_BIN_TO_PATH]
    [ENABLE_INSTALL]
    [MAKEFILE <makefileName>]
    [DISABLE_PARALLEL]
    [LOGFILE_BASE <logfilebase>]
)
```

`vcpkg_make_build` builds an already-configured make project.
You can use the alias [`vcpkg_make_install()`] function
if the Makefile build system supports the `install` TARGET,
and this is something we recommend doing whenever possible.
Otherwise, you can directly call `vcpkg_make_build` without `ENABLE_INSTALL`.

By default, `vcpkg_make_build` will call the `Makefile` in the build directory
and build all the targets.

If the makefile comes from another path or the name is not `Makefile`, please
pass `MAKEFILE` and set the absolute path.
Please pass `BUILD_TARGET` to select the needed targets.

When `ENABLE_INSTALL` is enabled, `vcpkg_make_build` will install all targets
unless `INSTALL_TARGET` is declared as some specific targets.

`LOGFILE_BASE` is used to set the base of the logfile names;
by default, this is `build`, and thus the logfiles end up being something like
`build-x86-windows-dbg.log`; if you use `vcpkg_cmake_install`,
this is set to `install`, so you'll get log names like `install-x86-windows-dbg.log`.

For build systems that are buggy when run in parallel,
using `DISABLE_PARALLEL` will run the build with only one job.

Finally, `ADD_BIN_TO_PATH` adds the appropriate (either release or debug)
`bin/` directories to the path during the build,
such that executables run during the build will be able to access those DLLs.

## Notes:
This command should be preceded by a call to [`vcpkg_make_configure()`](vcpkg_make_configure.md).
You can use the alias [`vcpkgl_make_install()`](vcpkgl_make_install.md) function if your makefile
supports the "install" target.

## Examples

* [x264](https://github.com/Microsoft/vcpkg/blob/master/ports/x264/portfile.cmake)
* [tcl](https://github.com/Microsoft/vcpkg/blob/master/ports/tcl/portfile.cmake)
* [freexl](https://github.com/Microsoft/vcpkg/blob/master/ports/freexl/portfile.cmake)
* [libosip2](https://github.com/Microsoft/vcpkg/blob/master/ports/libosip2/portfile.cmake)
#]===]

if(Z_VCPKG_MAKE_BUILD_GUARD)
    return()
endif()
set(Z_VCPKG_MAKE_BUILD_GUARD ON CACHE INTERNAL "guard variable")

function(vcpkg_make_build)
    z_vcpkg_get_cmake_vars(cmake_vars_file)
    include("${cmake_vars_file}")

    # parse parameters such that semicolons in options arguments to COMMAND don't get erased
    cmake_parse_arguments(PARSE_ARGV 0 arg
        "ADD_BIN_TO_PATH;ENABLE_INSTALL;DISABLE_PARALLEL"
        "LOGFILE_BASE;BUILD_TARGET;MAKEFILE;INSTALL_TARGET"
        "OPTIONS"
    )

    if(DEFINED arg_UNPARSED_ARGUMENTS)
        message(FATAL_ERROR "vcpkg_make_build was passed extra arguments: ${arg_UNPARSED_ARGUMENTS}")
    endif()

    if(NOT DEFINED arg_LOGFILE_BASE)
        set(arg_LOGFILE_BASE "build")
    endif()

    if(NOT DEFINED arg_BUILD_TARGET)
        set(arg_BUILD_TARGET "all")
    endif()

    if (NOT DEFINED arg_MAKEFILE)
        set(arg_MAKEFILE Makefile)
    endif()

    if(NOT DEFINED arg_INSTALL_TARGET)
        set(arg_INSTALL_TARGET "install")
    endif()

    if(WIN32)
        set(Z_VCPKG_INSTALLED ${CURRENT_INSTALLED_DIR})
    else()
        string(REPLACE " " "\ " Z_VCPKG_INSTALLED "${CURRENT_INSTALLED_DIR}")
    endif()

    vcpkg_list(SET make_opts)
    vcpkg_list(SET install_opts)
    if (CMAKE_HOST_WIN32)
        set(path_backup "$ENV{PATH}")
        vcpkg_add_to_path(PREPEND "${SCRIPTS}/buildsystems/make_wrapper")
        if(NOT DEFINED Z_VCPKG_MAKE)
            vcpkg_acquire_msys(MSYS_ROOT)
            find_program(Z_VCPKG_MAKE make PATHS "${MSYS_ROOT}/usr/bin" NO_DEFAULT_PATH REQUIRED)
        endif()
        set(make_command "${Z_VCPKG_MAKE}")
        vcpkg_list(SET make_opts ${arg_OPTIONS} ${arg_MAKE_OPTIONS} -j ${VCPKG_CONCURRENCY} --trace -f ${arg_MAKEFILE} ${arg_BUILD_TARGET})
        vcpkg_list(SET no_parallel_make_opts ${arg_OPTIONS} ${arg_MAKE_OPTIONS} -j 1 --trace -f ${arg_MAKEFILE} ${arg_BUILD_TARGET})

        string(REPLACE " " [[\ ]] vcpkg_package_prefix "${CURRENT_PACKAGES_DIR}")
        string(REGEX REPLACE [[([a-zA-Z]):/]] [[/\1/]] vcpkg_package_prefix "${vcpkg_package_prefix}")
        vcpkg_list(SET install_opts -j ${VCPKG_CONCURRENCY} --trace -f ${arg_MAKEFILE} ${arg_INSTALL_TARGET} DESTDIR=${vcpkg_package_prefix})
        #TODO: optimize for install-data (release) and install-exec (release/debug)
    else()
        if(VCPKG_HOST_IS_OPENBSD)
            find_program(Z_VCPKG_MAKE gmake REQUIRED)
        else()
            find_program(Z_VCPKG_MAKE make REQUIRED)
        endif()
        set(make_command "${Z_VCPKG_MAKE}")
        vcpkg_list(SET make_opts ${arg_MAKE_OPTIONS} V=1 -j ${VCPKG_CONCURRENCY} -f ${arg_MAKEFILE} ${arg_BUILD_TARGET})
        vcpkg_list(SET no_parallel_make_opts ${arg_MAKE_OPTIONS} V=1 -j 1 -f ${arg_MAKEFILE} ${arg_BUILD_TARGET})
        vcpkg_list(SET install_opts -j ${VCPKG_CONCURRENCY} -f ${arg_MAKEFILE} ${arg_INSTALL_TARGET} DESTDIR=${CURRENT_PACKAGES_DIR})
    endif()

    # Since includes are buildtype independent those are setup by vcpkg_make_configure
    vcpkg_backup_env_variables(VARS LIB LIBPATH LIBRARY_PATH LD_LIBRARY_PATH)

    foreach(buildtype IN ITEMS "debug" "release")
        if(NOT DEFINED VCPKG_BUILD_TYPE OR VCPKG_BUILD_TYPE STREQUAL "${buildtype}")
            if("${buildtype}" STREQUAL "debug")
                set(short_buildtype "-dbg")
                set(cmake_buildtype "DEBUG")
                set(path_suffix "/debug")
            else()
                # In NO_DEBUG mode, we only use ${TARGET_TRIPLET} directory.
                set(short_buildtype "-rel")
                set(cmake_buildtype "RELEASE")
                set(path_suffix "")
            endif()

            set(working_directory "${CURRENT_BUILDTREES_DIR}/${TARGET_TRIPLET}${short_buildtype}")
            message(STATUS "Building ${TARGET_TRIPLET}${short_buildtype}")

            z_vcpkg_extract_cpp_flags_and_set_cflags_and_cxxflags("${cmake_buildtype}")

            if(VCPKG_LIBRARY_LINKAGE STREQUAL "static")
                set(LINKER_FLAGS_${cmake_buildtype} "${VCPKG_DETECTED_STATIC_LINKER_FLAGS_${cmake_buildtype}}")
            else() # dynamic
                set(LINKER_FLAGS_${cmake_buildtype} "${VCPKG_DETECTED_SHARED_LINKER_FLAGS_${cmake_buildtype}}")
            endif()
            if (CMAKE_HOST_WIN32 AND VCPKG_DETECTED_CMAKE_C_COMPILER MATCHES "cl.exe")
                set(LDFLAGS_${cmake_buildtype} "-L${Z_VCPKG_INSTALLED}${path_suffix}/lib -L${Z_VCPKG_INSTALLED}${path_suffix}/lib/manual-link")
                set(LINK_ENV_${cmake_buildtype} "$ENV{_LINK_} ${LINKER_FLAGS_${cmake_buildtype}}")
            else()
                set(LDFLAGS_${cmake_buildtype} "-L${Z_VCPKG_INSTALLED}${path_suffix}/lib -L${Z_VCPKG_INSTALLED}${path_suffix}/lib/manual-link ${LINKER_FLAGS_${cmake_buildtype}}")
            endif()
            
            # Setup environment
            set(ENV{CPPFLAGS} "${CPPFLAGS_${cmake_buildtype}}")
            set(ENV{CFLAGS} "${CFLAGS_${cmake_buildtype}}")
            set(ENV{CXXFLAGS} "${CXXFLAGS_${cmake_buildtype}}")
            set(ENV{RCFLAGS} "${VCPKG_DETECTED_CMAKE_RC_FLAGS_${cmake_buildtype}}")
            set(ENV{LDFLAGS} "${LDFLAGS_${cmake_buildtype}}")
            vcpkg_host_path_list(PREPEND ENV{LIB} "${Z_VCPKG_INSTALLED}${path_suffix}/lib/" "${Z_VCPKG_INSTALLED}${path_suffix}/lib/manual-link/")
            vcpkg_host_path_list(PREPEND ENV{LIBPATH} "${Z_VCPKG_INSTALLED}${path_suffix}/lib/" "${Z_VCPKG_INSTALLED}${path_suffix}/lib/manual-link/")
            vcpkg_host_path_list(PREPEND ENV{LIBRARY_PATH} "${Z_VCPKG_INSTALLED}${path_suffix_${buildtype}}/lib/" "${Z_VCPKG_INSTALLED}${path_suffix}/lib/manual-link/")
            #vcpkg_host_path_list(PREPEND ENV{LD_LIBRARY_PATH} "${Z_VCPKG_INSTALLED}${path_suffix}/lib/" "${Z_VCPKG_INSTALLED}${path_suffix_${buildtype}}/lib/manual-link/")

            if(LINK_ENV_${_VAR_SUFFIX})
                set(config_link_backup "$ENV{_LINK_}")
                set(ENV{_LINK_} "${LINK_ENV_${_VAR_SUFFIX}}")
            endif()

            if(arg_ADD_BIN_TO_PATH)
                set(env_backup_path "$ENV{PATH}")
                vcpkg_add_to_path(PREPEND "${CURRENT_INSTALLED_DIR}${path_suffix}/bin")
            endif()

            vcpkg_list(SET make_cmd_line ${make_command} ${make_opts})
            vcpkg_list(SET no_parallel_make_cmd_line ${make_command} ${no_parallel_make_opts})

            if (arg_DISABLE_PARALLEL)
                vcpkg_execute_build_process(
                        COMMAND ${no_parallel_make_cmd_line}
                        WORKING_DIRECTORY "${working_directory}"
                        LOGNAME "${arg_LOGFILE_BASE}-${TARGET_TRIPLET}${short_buildtype}"
                )
            else()
                vcpkg_execute_build_process(
                        COMMAND ${make_cmd_line}
                        NO_PARALLEL_COMMAND ${no_parallel_make_cmd_line}
                        WORKING_DIRECTORY "${working_directory}"
                        LOGNAME "${arg_LOGFILE_BASE}-${TARGET_TRIPLET}${short_buildtype}"
                )
            endif()

            file(READ "${CURRENT_BUILDTREES_DIR}/${arg_LOGFILE_BASE}-${TARGET_TRIPLET}${short_buildtype}-out.log" logdata) 
            if(logdata MATCHES "Warning: linker path does not have real file for library")
                message(FATAL_ERROR "libtool could not find a file being linked against!")
            endif()

            if (arg_ENABLE_INSTALL)
                message(STATUS "Installing ${TARGET_TRIPLET}${short_buildtype}")
                vcpkg_list(SET make_cmd_line ${make_command} ${install_opts})
                vcpkg_execute_build_process(
                    COMMAND ${make_cmd_line}
                    WORKING_DIRECTORY "${working_directory}"
                    LOGNAME "install-${TARGET_TRIPLET}${short_buildtype}"
                )
            endif()

            if(config_link_backup)
                set(ENV{_LINK_} "${config_link_backup}")
                unset(config_link_backup)
            endif()

            if(arg_ADD_BIN_TO_PATH)
                set(ENV{PATH} "${env_backup_path}")
            endif()
        endif()
    endforeach()

    if (arg_ENABLE_INSTALL)
        string(REGEX REPLACE "([a-zA-Z]):/" "/\\1/" Z_VCPKG_INSTALL_PREFIX "${CURRENT_INSTALLED_DIR}")
        file(REMOVE_RECURSE "${CURRENT_PACKAGES_DIR}_tmp")
        file(RENAME "${CURRENT_PACKAGES_DIR}" "${CURRENT_PACKAGES_DIR}_tmp")
        file(RENAME "${CURRENT_PACKAGES_DIR}_tmp${Z_VCPKG_INSTALL_PREFIX}" "${CURRENT_PACKAGES_DIR}")
        file(REMOVE_RECURSE "${CURRENT_PACKAGES_DIR}_tmp")
    endif()

    # Remove libtool files since they contain absolute paths and are not necessary. 
    file(GLOB_RECURSE libtool_files "${CURRENT_PACKAGES_DIR}/**/*.la")
    if(libtool_files)
        file(REMOVE ${libtool_files})
    endif()

    if (CMAKE_HOST_WIN32)
        set(ENV{PATH} "${path_backup}")
    endif()

    vcpkg_restore_env_variables(VARS LIB LIBPATH LIBRARY_PATH LD_LIBRARY_PATH)
endfunction()
