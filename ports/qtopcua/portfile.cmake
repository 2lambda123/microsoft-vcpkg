set(SCRIPT_PATH "${CURRENT_INSTALLED_DIR}/share/qtbase")
include("${SCRIPT_PATH}/qt_install_submodule.cmake")

set(${PORT}_PATCHES build.patch)
# General features:
vcpkg_check_features(OUT_FEATURE_OPTIONS FEATURE_OPTIONS
FEATURES
    "open62541"      FEATURE_open62541
    "open62541"      FEATURE_open62541-security
    "uacpp"          FEATURE_uacpp
    "ns0idnames"     FEATURE_ns0idnames
    "ns0idgenerator" FEATURE_ns0idgenerator
INVERTED_FEATURES
    )
if("open62541" IN_LIST FEATURES)
    list(APPEND FEATURE_OPTIONS -DINPUT_open62541=system)
else()
    list(APPEND FEATURE_OPTIONS -DINPUT_open62541=no)
endif()

if(NOT "open62541" IN_LIST FEATURES AND NOT "gds" IN_LIST FEATURES)
    list(APPEND FEATURE_OPTIONS -DCMAKE_DISABLE_FIND_PACKAGE_WrapOpenSSL=ON)
endif()

qt_install_submodule(PATCHES    ${${PORT}_PATCHES}
                     CONFIGURE_OPTIONS
                     CONFIGURE_OPTIONS_RELEASE
                     CONFIGURE_OPTIONS_DEBUG
                    )
                    


#INPUT_open62541
#open62541
#uacpp
#ns0idnames
#ns0idgenerator
#gds -> RequiresWrapOpenSSL
#open62541-security -> Openssl and open62541

# open62541 is a port 