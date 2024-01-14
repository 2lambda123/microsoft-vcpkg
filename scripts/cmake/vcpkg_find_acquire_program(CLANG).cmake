set(program_name clang)
set(tool_subdirectory "clang-17.0.6")
set(program_version 17.0.6)
set(version_command "--version")
if(CMAKE_HOST_WIN32)
    set(paths_to_search
        # Support LLVM in Visual Studio 2019
        "${DOWNLOADS}/tools/${tool_subdirectory}-windows/bin"
        "${DOWNLOADS}/tools/clang/${tool_subdirectory}/bin")

    if(DEFINED ENV{PROCESSOR_ARCHITEW6432})
        set(host_arch "$ENV{PROCESSOR_ARCHITEW6432}")
    else()
        set(host_arch "$ENV{PROCESSOR_ARCHITECTURE}")
    endif()

    if(host_arch MATCHES "64")
        set(download_urls "https://github.com/llvm/llvm-project/releases/download/llvmorg-${program_version}/LLVM-${program_version}-win64.exe")
        set(download_filename "LLVM-${program_version}-win64.7z.exe")
        set(download_sha512 4ac5ef7dac28455c895383d41d140d4c6aaf7c4789b92947a58e2f3e72069a2037517675e4b815f1c8696d3e0fb3f0a03d7a13e62255818c613abe99436f0663)
    else()
        set(download_urls "https://github.com/llvm/llvm-project/releases/download/llvmorg-${program_version}/LLVM-${program_version}-win32.exe")
        set(download_filename "LLVM-${program_version}-win32.7z.exe")
        set(download_sha512 0)
    endif()
endif()
set(brew_package_name "llvm")
set(apt_package_name "clang")
