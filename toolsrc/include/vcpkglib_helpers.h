#pragma once

#include <unordered_map>

namespace vcpkg {namespace details
{
    std::string optional_field(const std::unordered_map<std::string, std::string>& fields, const std::string& fieldname);

    std::string required_field(const std::unordered_map<std::string, std::string>& fields, const std::string& fieldname);

    std::vector<std::string> parse_depends(const std::string& depends_string);
}}
