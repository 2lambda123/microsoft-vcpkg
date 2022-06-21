### Steps to update the qt6 ports
## 1. Change QT_VERSION below to the new version
## 2. Set QT_UPDATE_VERSION to 1
## 3. Add any new Qt modules to QT_PORTS
## 4. Run a build of `qtbase`
## 5. Fix any intermediate failures by adding the module into QT_FROM_GITHUB, QT_FROM_GITHUB_BRANCH, or QT_FROM_QT_GIT as appropriate
## 6. The build should fail with "Done downloading version and emitting hashes." This will have changed out the vcpkg.json versions of the qt ports and rewritten qt_port_data.cmake
## 7. Set QT_UPDATE_VERSION back to 0

set(QT_VERSION 6.3.0)
set(QT_UPDATE_VERSION 0)

if(PORT MATCHES "qtquickcontrols2")
    set(VCPKG_POLICY_EMPTY_PACKAGE enabled)
    message(STATUS "qtquickcontrols2 is integrated in qtdeclarative since Qt 6.2. Please remove your dependency on it!")
    return()
endif()

### Setting up the git tag.

set(QT_PORTS qt
             qtbase
             qttools
             qtdeclarative
             qtsvg
             qt5compat
             qtshadertools
             qtquicktimeline
             qtquick3d
             qttranslations
             qtwayland
             qtdoc
             qtcoap
             qtopcua
             qtimageformats
             qtmqtt
             qtnetworkauth)
             # qtquickcontrols2 -> moved into qtdeclarative
if(QT_VERSION VERSION_GREATER_EQUAL 6.1)
    list(APPEND QT_PORTS
             ## New in 6.1
             qtactiveqt
             qtdatavis3d
             qtdeviceutilities
             qtlottie
             qtscxml
             qtvirtualkeyboard
             qtcharts)
endif()
if(QT_VERSION VERSION_GREATER_EQUAL 6.2)
    list(APPEND QT_PORTS
             ## New in 6.2
             qtconnectivity
             qtpositioning
             qtlocation
             qtmultimedia
             qtremoteobjects
             qtsensors
             qtserialbus
             qtserialport
             qtwebchannel
             qtwebengine
             qtwebsockets
             qtwebview)
endif()
if(QT_VERSION VERSION_GREATER_EQUAL 6.2.2)
    list(APPEND QT_PORTS
             ## New in 6.2.2
             qtinterfaceframework
             qtapplicationmanager)
endif()

# 1. By default, modules come from the official release
# 2. These modules are mirrored to github and have tags matching the release
set(QT_FROM_GITHUB qtcoap qtopcua qtmqtt qtapplicationmanager)
# 3. These modules are mirrored to github and have branches matching the release
set(QT_FROM_GITHUB_BRANCH qtdeviceutilities qtlocation)
# 4. These modules are not mirrored to github and not part of the release
set(QT_FROM_QT_GIT qtinterfaceframework)

function(qt_get_url_filename qt_port out_url out_filename)
    if("${qt_port}" IN_LIST QT_FROM_GITHUB)
        set(url "https://github.com/qt/${qt_port}/archive/v${QT_VERSION}.tar.gz")
        set(filename "qt-${qt_port}-v${QT_VERSION}.tar.gz")
    elseif("${qt_port}" IN_LIST QT_FROM_GITHUB_BRANCH)
        set(url "https://github.com/qt/${qt_port}/archive/${QT_VERSION}.tar.gz")
        set(filename "qt-${qt_port}-${QT_VERSION}.tar.gz")
    else()
        string(SUBSTRING "${QT_VERSION}" 0 3 qt_major_minor)
        set(url "https://download.qt.io/archive/qt/${qt_major_minor}/${QT_VERSION}/submodules/${qt_port}-everywhere-src-${QT_VERSION}.tar.xz")
        set(filename "${qt_port}-everywhere-src-${QT_VERSION}.tar.xz")
    endif()
    set(${out_url} "${url}" PARENT_SCOPE)
    set(${out_filename} "${filename}" PARENT_SCOPE)
endfunction()

if(QT_UPDATE_VERSION)
    if(NOT PORT STREQUAL "qtbase")
        message(FATAL_ERROR "QT_UPDATE_VERSION must be used from the root 'qtbase' package")
    endif()
    set(VCPKG_USE_HEAD_VERSION 1)
    set(msg "" CACHE INTERNAL "")
    foreach(qt_port IN LISTS QT_PORTS)
        set(port_json "${CMAKE_CURRENT_LIST_DIR}/../../${qt_port}/vcpkg.json")
        if(EXISTS "${port_json}")
            file(READ "${port_json}" _control_contents)
            string(REGEX REPLACE "\"version-(string|semver)\": [^\n]+\n" "\"version-semver\": \"${QT_VERSION}\",\n" _control_contents "${_control_contents}")
            string(REGEX REPLACE "[^\n]+\"port-version\": [^\n]+\n" "" _control_contents "${_control_contents}")
            file(WRITE "${port_json}" "${_control_contents}")
        endif()
        if(qt_port STREQUAL "qt")
            continue()
        endif()
        if("${qt_port}" IN_LIST QT_FROM_QT_GIT)
            execute_process(
                COMMAND git ls-remote -t https://code.qt.io/cgit/qt/${qt_port}.git "v${QT_VERSION}"
                OUTPUT_VARIABLE out
            )
            string(SUBSTRING "${out}" 0 40 tag_sha)
            string(APPEND msg "set(${qt_port}_REF ${tag_sha})\n")
        else()
            qt_get_url_filename("${qt_port}" url filename)
            vcpkg_download_distfile(archive
                URLS "${url}"
                FILENAME "${filename}"
                SKIP_SHA512
            )
            file(SHA512 "${archive}" hash)
            string(APPEND msg "set(${qt_port}_HASH \"${hash}\")\n")
        endif()
    endforeach()

    file(WRITE "${CMAKE_CURRENT_LIST_DIR}/qt_port_data.cmake" "${msg}")
    message(FATAL_ERROR "Done downloading version and emitting hashes.")
endif()

include("${CMAKE_CURRENT_LIST_DIR}/qt_port_data.cmake")
