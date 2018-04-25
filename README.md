# Vcpkg <a href="#">![](https://devdiv.visualstudio.com/_apis/public/build/definitions/0bdbc590-a062-4c3f-b0f6-9383f67865ee/8476/badge)</a>

## Overview
Vcpkg helps you manage your C and C++ libraries on Windows, Linux and  macOS. This tool and ecosystem are currently in a preview state; your involvement is vital to its success.

For short description of available commands, run `vcpkg help`.

## Quick Start
Prerequisites:
- Git
- *Optional: CMake 3.10.2*

To get started:
```
> git clone https://github.com/Microsoft/vcpkg
> cd vcpkg

PS> ./bootstrap-vcpkg.bat

Ubuntu:~/$ ./bootstrap-vcpkg.sh
```

Then, to hook up user-wide integration, run (note: requires admin on first use)
```
> ./vcpkg integrate install
```

Install any packages with
```
> ./vcpkg install sdl2 curl
```

The best way to use installed libraries with Cmake is via the toolchain file `scripts\buildsystems\vcpkg.cmake`. To use this file, you simply need to add it onto your CMake command line as `-DCMAKE_TOOLCHAIN_FILE=[vcpkg root]\scripts\buildsystems\vcpkg.cmake`.


If you are a Visual Studio 2017 or 2015 user, you can create a New Project (or open an existing one). All installed libraries are immediately ready to be `#include`'d and used in your project without additional configuration.

For more information, see our [using a package](docs/examples/using-sqlite.md) example for the specifics. 

Additional notes on macOS and Linux support can be found in the [official announcement](https://blogs.msdn.microsoft.com/vcblog/2018/04/24/announcing-a-single-c-library-manager-for-linux-macos-and-windows-vcpkg/).

## Tab-Completion / Auto-Completion

`Vcpkg` supports auto-completion of commands, package names, options etc. To enable tab-completion in Powershell, use
```
.\vcpkg integrate powershell
```
and restart Powershell.


## Examples
See the [documentation](docs/index.md) for specific walkthroughs, including [using a package](docs/examples/using-sqlite.md) and [adding a new package](docs/examples/packaging-zlib.md).

Our docs are now also available online at ReadTheDocs: <https://vcpkg.readthedocs.io/>!

See a 4 minute [video demo](https://www.youtube.com/watch?v=y41WFKbQFTw).

## Contributing
Vcpkg is built with your contributions. Here are some ways you can contribute:

* [Submit Issues](https://github.com/Microsoft/vcpkg/issues) in vcpkg or existing packages
* [Submit Fixes and New Packages](https://github.com/Microsoft/vcpkg/pulls)

Please refer to our [Contribution guidelines](CONTRIBUTING.md) for more details.

This project has adopted the [Microsoft Open Source Code of Conduct](https://opensource.microsoft.com/codeofconduct/). For more information see the [Code of Conduct FAQ](https://opensource.microsoft.com/codeofconduct/faq/) or contact [opencode@microsoft.com](mailto:opencode@microsoft.com) with any additional questions or comments.

## License

Code licensed under the [MIT License](LICENSE.txt).
