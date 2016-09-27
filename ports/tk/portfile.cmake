include(vcpkg_common_functions)
vcpkg_download_distfile(ARCHIVE
    URLS "http://prdownloads.sourceforge.net/tcl/tk8.6.5-src.tar.gz"
    FILENAME "tk8.6.5-src.tar.gz"
    MD5 11dbbd425c3e0201f20d6a51482ce6c4
)

find_program(NMAKE nmake)

if(NOT EXISTS ${CURRENT_BUILDTREES_DIR}/x86-windows-rel)
    message(STATUS "Extracting source ${ARCHIVE} for Release")
    file(MAKE_DIRECTORY ${CURRENT_BUILDTREES_DIR}/x86-windows-rel)
    vcpkg_execute_required_process(
        COMMAND ${CMAKE_COMMAND} -E tar xjf ${ARCHIVE}
        WORKING_DIRECTORY ${CURRENT_BUILDTREES_DIR}/x86-windows-rel
        LOGNAME extract-x86-windows-rel
    )
endif()
if(NOT EXISTS ${CURRENT_BUILDTREES_DIR}/x86-windows-dbg)
    message(STATUS "Extracting source ${ARCHIVE} for Debug")
    file(MAKE_DIRECTORY ${CURRENT_BUILDTREES_DIR}/x86-windows-dbg)
    vcpkg_execute_required_process(
        COMMAND ${CMAKE_COMMAND} -E tar xjf ${ARCHIVE}
        WORKING_DIRECTORY ${CURRENT_BUILDTREES_DIR}/x86-windows-dbg
        LOGNAME extract-x86-windows-dbg
    )
endif()
message(STATUS "Extracting done")

message(STATUS "Building x86-windows-rel")
vcpkg_execute_required_process(
    COMMAND ${NMAKE} -f makefile.vc release TCLDIR=${CURRENT_BUILDTREES_DIR}\\x86-windows-rel\\tcl8.6.5
    WORKING_DIRECTORY ${CURRENT_BUILDTREES_DIR}/x86-windows-rel/tk8.6.5/win
    LOGNAME build-x86-windows-rel
)
message(STATUS "Building x86-windows-rel done")

message(STATUS "Building x86-windows-dbg")
vcpkg_execute_required_process(
    COMMAND ${NMAKE} -f makefile.vc release OPTS=symbols TCLDIR=${CURRENT_BUILDTREES_DIR}\\x86-windows-dbg\\tcl8.6.5
    WORKING_DIRECTORY ${CURRENT_BUILDTREES_DIR}/x86-windows-dbg/tk8.6.5/win
    LOGNAME build-x86-windows-dbg
)
message(STATUS "Building x86-windows-dbg done")

message(STATUS "Installing x86-windows-rel")
vcpkg_execute_required_process(
    COMMAND ${NMAKE} -f makefile.vc install INSTALLDIR=${CURRENT_PACKAGES_DIR} SCRIPT_INSTALL_DIR=${CURRENT_PACKAGES_DIR}\\share\\tcltk\\tk8.6
    WORKING_DIRECTORY ${CURRENT_BUILDTREES_DIR}/x86-windows-rel/tk8.6.5/win
    LOGNAME install-x86-windows-rel
)
message(STATUS "Installing x86-windows-rel done")

message(STATUS "Installing x86-windows-dbg")
vcpkg_execute_required_process(
    COMMAND ${NMAKE} -f makefile.vc install INSTALLDIR=${CURRENT_PACKAGES_DIR}\\debug OPTS=symbols SCRIPT_INSTALL_DIR=${CURRENT_PACKAGES_DIR}\\debug\\share\\tcltk\\tk8.6
    WORKING_DIRECTORY ${CURRENT_BUILDTREES_DIR}/x86-windows-dbg/tk8.6.5/win
    LOGNAME install-x86-windows-dbg
)
message(STATUS "Installing x86-windows-dbg done")

file(INSTALL ${CURRENT_BUILDTREES_DIR}/x86-windows-rel/tk8.6.5/license.terms DESTINATION ${CURRENT_PACKAGES_DIR}/share/tk RENAME copyright)
vcpkg_copy_pdbs()
