include("${CMAKE_CURRENT_LIST_DIR}/qt_install_copyright.cmake")
include("${CMAKE_CURRENT_LIST_DIR}/qt_port_hashes.cmake")
set(PORT_DEBUG ON)
function(qt_install_submodule)
    cmake_parse_arguments(PARSE_ARGV 0 "_qis" ""
                          ""
                          "PATCHES;TOOL_NAMES;CONFIGURE_OPTIONS;CONFIGURE_OPTIONS_DEBUG;CONFIGURE_OPTIONS_RELEASE")

    vcpkg_find_acquire_program(PERL) # Perl is probably required by all qt ports for syncqt
    get_filename_component(PERL_PATH ${PERL} DIRECTORY)
    vcpkg_add_to_path(${PERL_PATH})
    vcpkg_find_acquire_program(PYTHON3) # Python is required by some qt ports
    get_filename_component(PYTHON3_PATH ${PYTHON3} DIRECTORY)
    vcpkg_add_to_path(${PYTHON3_PATH})

    vcpkg_from_github(
        OUT_SOURCE_PATH SOURCE_PATH
        REPO qt/${PORT}
        REF ${${PORT}_REF}
        SHA512 ${${PORT}_HASH}
        HEAD_REF master
        PATCHES ${_qis_PATCHES}
    )

    if(VCPKG_TARGET_IS_WINDOWS)
        if(NOT ${PORT} MATCHES "qtbase")
            list(APPEND _qis_CONFIGURE_OPTIONS -DQT_SYNCQT:PATH="${CURRENT_INSTALLED_DIR}/tools/qtbase/syncqt.pl")
        endif()
        set(PERL_OPTION -DHOST_PERL:PATH="${PERL}")
    else()
        if(NOT ${PORT} MATCHES "qtbase")
            list(APPEND _qis_CONFIGURE_OPTIONS -DQT_SYNCQT:PATH=${CURRENT_INSTALLED_DIR}/tools/qtbase/syncqt.pl)
        endif()
        set(PERL_OPTION -DHOST_PERL:PATH=${PERL})
    endif()

    vcpkg_configure_cmake(
        SOURCE_PATH "${SOURCE_PATH}"
        PREFER_NINJA
        OPTIONS 
            #-DQT_HOST_PATH=<somepath> # For crosscompiling
            #-DQT_PLATFORM_DEFINITION_DIR=mkspecs/win32-msvc
            #-DQT_QMAKE_TARGET_MKSPEC=win32-msvc
            #-DQT_USE_CCACHE
            -DQT_NO_MAKE_EXAMPLES:BOOL=TRUE
            -DQT_NO_MAKE_TESTS:BOOL=TRUE
            ${PERL_OPTION}
            -DINSTALL_DESCRIPTIONSDIR:STRING=modules
            -DINSTALL_LIBEXECDIR:STRING=bin
            -DINSTALL_PLUGINSDIR:STRING=plugins
            -DINSTALL_QMLDIR:STRING=qml
            -DINSTALL_TRANSLATIONSDIR:STRING=translations
            ${_qis_CONFIGURE_OPTIONS}
        OPTIONS_RELEASE
            ${_qis_CONFIGURE_OPTIONS_RELEASE}
        OPTIONS_DEBUG
            -DINPUT_debug:BOOL=ON
            -DINSTALL_DOCDIR:STRING=../doc
            -DINSTALL_INCLUDEDIR:STRING=../include
            -DINSTALL_TRANSLATIONSDIR:STRING=../translations
            ${_qis_CONFIGURE_OPTIONS_DEBUG}
    )

    #Check QtQmakeHelpers.cmake for changes in:
    #qt_add_string_to_qconfig_cpp("${INSTALL_BINDIR}") # TODO: Host-specific
    #qt_add_string_to_qconfig_cpp("${INSTALL_LIBDIR}") # TODO: Host-specific
    #qt_add_string_to_qconfig_cpp("${INSTALL_DATADIR}") # TODO: Host-specific

    vcpkg_install_cmake(ADD_BIN_TO_PATH)
    vcpkg_copy_pdbs()

    ## Handle CMake files. 
    set(COMPONENTS)
    file(GLOB COMPONENTS_OR_FILES LIST_DIRECTORIES true "${CURRENT_PACKAGES_DIR}/share/Qt6*")
    foreach(_glob IN LISTS COMPONENTS_OR_FILES)
        if(IS_DIRECTORY "${_glob}")
            string(REPLACE "${CURRENT_PACKAGES_DIR}/share/Qt6" "" _component "${_glob}")
            debug_message("Adding cmake component: '${_component}'")
            list(APPEND COMPONENTS ${_component})
        endif()
    endforeach()

    foreach(_comp IN LISTS COMPONENTS)
        if(EXISTS "${CURRENT_PACKAGES_DIR}/share/Qt6${_comp}")
            vcpkg_fixup_cmake_targets(CONFIG_PATH share/Qt6${_comp} TARGET_PATH share/Qt6${_comp})
            # Would rather put it into share/cmake as before but the import_prefix correction in vcpkg_fixup_cmake_targets is working against that. 
        else()
            message(STATUS "WARNING: Qt component ${_comp} not found/built!")
        endif()
    endforeach()
    #fix debug plugin paths (should probably be fixed in vcpkg_fixup_pkgconfig)
    file(GLOB_RECURSE DEBUG_CMAKE_TARGETS "${CURRENT_PACKAGES_DIR}/share/**/*Targets-debug.cmake")
    message(STATUS "DEBUG_CMAKE_TARGETS:${DEBUG_CMAKE_TARGETS}")
    foreach(_debug_target IN LISTS DEBUG_CMAKE_TARGETS)
        vcpkg_replace_string("${_debug_target}" "{_IMPORT_PREFIX}/plugins" "{_IMPORT_PREFIX}/debug/plugins")
    endforeach()

    ## Handle Tools
    foreach(_tool IN LISTS _qis_TOOL_NAMES)
        if(NOT EXISTS "${CURRENT_PACKAGES_DIR}/bin/${_tool}${VCPKG_TARGET_EXECUTABLE_SUFFIX}")
            debug_message("Removed '${_tool}' from copy tools list since it was not found!")
            list(REMOVE_ITEM _qis_TOOL_NAMES ${_tool})
        endif()
    endforeach()
    if(_qis_TOOL_NAMES)
        vcpkg_copy_tools(TOOL_NAMES ${_qis_TOOL_NAMES} AUTO_CLEAN)
        if(EXISTS "${CURRENT_INSTALLED_DIR}/plugins")
            file(COPY "${CURRENT_INSTALLED_DIR}/plugins" DESTINATION "${CURRENT_PACKAGES_DIR}/tools/${PORT}")
        endif()
        if(EXISTS "${CURRENT_PACKAGES_DIR}/plugins")
            file(COPY "${CURRENT_PACKAGES_DIR}/plugins" DESTINATION "${CURRENT_PACKAGES_DIR}/tools/${PORT}")
        endif()
    endif()

    file(REMOVE_RECURSE "${CURRENT_PACKAGES_DIR}/debug/mkspecs"
                        "${CURRENT_PACKAGES_DIR}/debug/lib/cmake/"
                        "${CURRENT_PACKAGES_DIR}/debug/share"
                        "${CURRENT_PACKAGES_DIR}/lib/cmake/"
                        )

    if(VCPKG_LIBRARY_LINKAGE STREQUAL "static")
        file(GLOB_RECURSE _bin_files "${CURRENT_PACKAGES_DIR}/bin/*")
        if(NOT _bin_files) # Only clean if empty otherwise let vcpkg throw and error. 
            file(REMOVE_RECURSE "${CURRENT_PACKAGES_DIR}/bin/" "${CURRENT_PACKAGES_DIR}/debug/bin/")
        endif()
    endif()

    qt_install_copyright("${SOURCE_PATH}")
endfunction()
