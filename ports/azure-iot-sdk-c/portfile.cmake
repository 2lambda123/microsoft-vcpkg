include(vcpkg_common_functions)

vcpkg_check_linkage(ONLY_STATIC_LIBRARY)

if("public-preview" IN_LIST FEATURES)
    vcpkg_from_github(
        OUT_SOURCE_PATH SOURCE_PATH
        REPO Azure/azure-iot-sdk-c
        REF abb906e01060f7c837cbb6522f75f31c7b10fa4a
        SHA512 9549a799de741964cea2c436a8990b78a04715c43237bb8c3837237e66aa43ada25d74001eada160cad3f5fe71cd32fc054584fade686d931cd51f4ae44d69bd
        HEAD_REF public-preview
        PATCHES improve-external-deps.patch
    )
else()
    vcpkg_from_github(
        OUT_SOURCE_PATH SOURCE_PATH
        REPO Azure/azure-iot-sdk-c
        REF f8d260df190f90c04114ca8ff7d83dd03d4dd80d
        SHA512 111331293cfbdbdac4a6460d293ec8650bee31940829852c27afc88cc6e742e96f71c996aa275dc5ed1f13e9fe19452d7b2685dde47bb7d6c135ebee58c50d21
        HEAD_REF master
        PATCHES improve-external-deps.patch
    )
endif()

if("use_prov_client" IN_LIST FEATURES)
    message(STATUS "use prov_client")
    set(USE_PROV_CLIENT 1)
else()
    message(STATUS "NO prov_client")
    set(USE_PROV_CLIENT 0)
endif()

file(COPY ${CURRENT_INSTALLED_DIR}/share/azure-c-shared-utility/azure_iot_build_rules.cmake DESTINATION ${SOURCE_PATH}/deps/azure-c-shared-utility/configs/)
file(COPY ${SOURCE_PATH}/configs/azure_iot_sdksFunctions.cmake DESTINATION ${CURRENT_PACKAGES_DIR}/share/cmake/azure_iot_sdks/)

vcpkg_configure_cmake(
    SOURCE_PATH ${SOURCE_PATH}
    PREFER_NINJA
    OPTIONS
        -Dskip_samples=ON
        -Duse_installed_dependencies=ON
        -Duse_default_uuid=ON
        -Dbuild_as_dynamic=OFF
        -Duse_edge_modules=ON
        -Duse_prov_client=${USE_PROV_CLIENT}
        -Dhsm_type_symm_key=${USE_PROV_CLIENT}
)

vcpkg_install_cmake()

vcpkg_fixup_cmake_targets(CONFIG_PATH cmake TARGET_PATH share/azure_iot_sdks)

file(REMOVE_RECURSE ${CURRENT_PACKAGES_DIR}/debug/include ${CURRENT_PACKAGES_DIR}/debug/share)

configure_file(${SOURCE_PATH}/LICENSE ${CURRENT_PACKAGES_DIR}/share/azure-iot-sdk-c/copyright COPYONLY)

vcpkg_copy_pdbs()

