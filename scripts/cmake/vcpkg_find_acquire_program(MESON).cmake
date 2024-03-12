set(program_name meson)
set(search_names meson meson.py)
set(interpreter PYTHON3)
set(apt_package_name "meson")
set(brew_package_name "meson")
set(version_command --version)
set(extra_search_args EXACT_VERSION_MATCH)
set(program_version 0.63.0)
set(ref bb91cea0d66d8d036063dedec1f194d663399cdf)
set(paths_to_search "${DOWNLOADS}/tools/meson/meson-${ref}")
set(download_urls "https://github.com/mesonbuild/meson/archive/${ref}.tar.gz")
set(download_filename "meson-${ref}.tar.gz")
set(download_sha512 e5888eb35dd4ab5fc0a16143cfbb5a7849f6d705e211a80baf0a8b753e2cf877a4587860a79cad129ec5f3474c12a73558ffe66439b1633d80b8044eceaff2da)
set(download_patches "meson-intl.patch;remove-freebsd-pcfile-specialization.patch")
