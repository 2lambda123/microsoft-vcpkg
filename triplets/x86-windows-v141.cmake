set(VCPKG_TARGET_ARCHITECTURE x86)
set(VCPKG_CRT_LINKAGE dynamic)
set(VCPKG_LIBRARY_LINKAGE static)
set(VCPKG_PLATFORM_TOOLSET v141)
if(PORT MATCHES "freetype|harfbuzz|libpng|pcre|openssl|libpq|qt5|zlib")
set(VCPKG_LIBRARY_LINKAGE dynamic)
endif()
