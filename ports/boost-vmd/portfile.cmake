# Automatically generated by scripts/boost/generate-ports.ps1

vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO boostorg/vmd
    REF boost-${VERSION}
    SHA512 75ef952018fd453958bd6a3d01c3c8ce75838fb90dd5a69ec2df4813d9fb53ec2f0434efd8ae5b820b55ead62babcab9e7d1fce1fceae0985f73da86538703fc
    HEAD_REF master
)

set(FEATURE_OPTIONS "")
boost_configure_and_install(
    SOURCE_PATH "${SOURCE_PATH}"
    OPTIONS ${FEATURE_OPTIONS}
)
