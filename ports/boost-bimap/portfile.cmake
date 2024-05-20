# Automatically generated by scripts/boost/generate-ports.ps1

vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO boostorg/bimap
    REF boost-${VERSION}
    SHA512 3703085a1105a7b33f5f63f39d95af09722b8ca4ac525697d673f6cc7c1f32cce1a6725ff68f39146c582cdb3e79e4f68044962ba4b31e951cdf0188e57c46ce
    HEAD_REF master
)

set(FEATURE_OPTIONS "")
boost_configure_and_install(
    SOURCE_PATH "${SOURCE_PATH}"
    OPTIONS ${FEATURE_OPTIONS}
)
