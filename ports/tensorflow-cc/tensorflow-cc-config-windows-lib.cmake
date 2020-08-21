message(WARNING "Tensorflow has vendored dependencies. You may need to manually include files from tensorflow-external")

set(tensorflow_cc_FOUND TRUE)

add_library(tensorflow_cc::tensorflow_cc-part1 STATIC IMPORTED)
set_target_properties(tensorflow_cc::tensorflow_cc-part1
	PROPERTIES
	IMPORTED_LOCATION "${VCPKG_INSTALLATION_ROOT}/installed/${TARGET_TRIPLET}/lib/tensorflow.lib"
	INTERFACE_INCLUDE_DIRECTORIES "${VCPKG_INSTALLATION_ROOT}/installed/${TARGET_TRIPLET}/include/tensorflow-external"
)
