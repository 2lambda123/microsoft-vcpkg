#include "pch.h"

#include <vcpkg/base/downloads.h>
#include <vcpkg/base/hash.h>
#include <vcpkg/base/system.h>
#include <vcpkg/base/system.process.h>
#include <vcpkg/base/util.h>

#if defined(_WIN32)
#include <VersionHelpers.h>
#endif

namespace vcpkg::Downloads
{
    void verify_downloaded_file_hash(const Files::Filesystem& fs,
                                     const std::string& url,
                                     const fs::path& path,
                                     const std::string& sha512)
    {
        std::string actual_hash = vcpkg::Hash::get_file_hash(VCPKG_LINE_INFO, fs, path, Hash::Algorithm::Sha512);

        // <HACK to handle NuGet.org changing nupkg hashes.>
        // This is the NEW hash for 7zip
        if (actual_hash == "a9dfaaafd15d98a2ac83682867ec5766720acf6e99d40d1a00d480692752603bf3f3742623f0ea85647a92374df"
                           "405f331afd6021c5cf36af43ee8db198129c0")
            // This is the OLD hash for 7zip
            actual_hash = "8c75314102e68d2b2347d592f8e3eb05812e1ebb525decbac472231633753f1d4ca31c8e6881a36144a8da26b257"
                          "1305b3ae3f4e2b85fc4a290aeda63d1a13b8";
        // </HACK>

        Checks::check_exit(VCPKG_LINE_INFO,
                           sha512 == actual_hash,
                           "File does not have the expected hash:\n"
                           "             url : [ %s ]\n"
                           "       File path : [ %s ]\n"
                           "   Expected hash : [ %s ]\n"
                           "     Actual hash : [ %s ]\n",
                           url,
                           path.u8string(),
                           sha512,
                           actual_hash);
    }

    void download_file(vcpkg::Files::Filesystem& fs,
                       const std::string& url,
                       const fs::path& download_path,
                       const std::string& sha512)
    {
        const std::string download_path_part = download_path.u8string() + ".part";
        auto download_path_part_path = fs::u8path(download_path_part);
        std::error_code ec;
        fs.remove(download_path, ec);
        fs.remove(download_path_part_path, ec);
#if defined(_WIN32)
        auto mirrorUrl = System::get_environment_variable("VCPKG_EXPERIMENTAL_MIRROR_URL");
        auto url_no_proto = url;
        if (mirrorUrl.has_value())
            url_no_proto = url_no_proto.substr(6); // drop ftp://
        else
            url_no_proto = url_no_proto.substr(8); // drop https://
        auto path_begin = Util::find(url_no_proto, '/');
        std::string hostname(url_no_proto.begin(), path_begin);
        std::string path(path_begin, url_no_proto.end());

        if (mirrorUrl.has_value())
            ftp_download_file(fs, download_path_part, hostname, path);
        else
        winhttp_download_file(fs, download_path_part, hostname, path);
#else
        const auto code = System::cmd_execute(
            Strings::format(R"(curl -L '%s' --create-dirs --output '%s')", url, download_path_part));
        Checks::check_exit(VCPKG_LINE_INFO, code == 0, "Could not download %s", url);
#endif

        verify_downloaded_file_hash(fs, url, download_path_part_path, sha512);
        fs.rename(download_path_part_path, download_path, VCPKG_LINE_INFO);
    }
}
