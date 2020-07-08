function(CreateNativeScriptApp _target _main _headers _plist _resources)
    include_directories("${RUNTIME_DIR}/**" ${NATIVESCRIPT_DEBUGGING_DIR} "${CMAKE_SOURCE_DIR}/NodeMobile.framework/Headers" "${CMAKE_SOURCE_DIR}/examples/Gameraww")
    link_directories(${WEBKIT_LINK_DIRECTORIES} "${LIBFFI_LIB_DIR}")

    set(FRAMEWORK_NAME "NodeMobile")
    add_executable(${_target} MACOSX_BUNDLE ${_headers} ${_main} ${_resources})

    set_target_properties(${_target} PROPERTIES
        XCODE_ATTRIBUTE_OTHER_LDFLAGS "${XCODE_ATTRIBUTE_OTHER_LDFLAGS} -framework ${FRAMEWORK_NAME}"
    )

    target_include_directories(${_target} PUBLIC
        "${CMAKE_SOURCE_DIR}/MyFrameworks/${FRAMEWORK_NAME}.framework"
    )

    target_link_libraries(${_target}
        "-ObjC"
        "-framework CoreGraphics"
        "-framework UIKit"
        "-framework MobileCoreServices"
        "-framework Security"
    )

    target_link_libraries(${_target}
        ${EXTRA_LIB})

    if(NOT ${BUILD_SHARED_LIBS})
        add_dependencies(${_target} NativeScript)
        target_link_libraries(${_target}
            libicucore.dylib
            libz.dylib
            libc++.dylib
            "-lNativeScript"
            "-L${NativeScriptFramework_BINARY_DIR}/$(CONFIGURATION)$(EFFECTIVE_PLATFORM_NAME)"
        )

        if(NOT ${EMBED_STATIC_DEPENDENCIES})
            target_link_libraries(${_target} ${WEBKIT_LIBRARIES} ffi)
        endif()
    else()
        add_dependencies(${_target} NativeScript)
        target_link_libraries(${_target}
            "-framework NativeScript"
            "-F${NativeScriptFramework_BINARY_DIR}/$(CONFIGURATION)$(EFFECTIVE_PLATFORM_NAME)/"
        )
        set_target_properties(${_target} PROPERTIES
            XCODE_ATTRIBUTE_LD_RUNPATH_SEARCH_PATHS    "@executable_path/Frameworks"
        )
        target_include_directories(${_target} PUBLIC
                "${CMAKE_SOURCE_DIR}/projects/MyApp/include/node")
        target_include_directories(${_target} PUBLIC
                        "${CMAKE_SOURCE_DIR}/projects/MyApp")

        # Create Frameworks directory in app bundle
        add_custom_command(
            TARGET
            ${_target}
            POST_BUILD COMMAND ${CMAKE_COMMAND} -E make_directory
            ${CMAKE_CURRENT_BINARY_DIR}/$(CONFIGURATION)$(EFFECTIVE_PLATFORM_NAME)/${_target}.app/Frameworks
        )

        # Copy the framework into the bundle
        add_custom_command(
            TARGET
            ${_target}
            POST_BUILD COMMAND ${CMAKE_COMMAND} -E copy_directory
            ${NativeScriptFramework_BINARY_DIR}/$(CONFIGURATION)$(EFFECTIVE_PLATFORM_NAME)/
            ${CMAKE_CURRENT_BINARY_DIR}/$(CONFIGURATION)$(EFFECTIVE_PLATFORM_NAME)/${_target}.app/Frameworks
        )

        # Codesign the framework in it's new spot
        add_custom_command(
            TARGET
            ${_target}
            POST_BUILD COMMAND codesign --force --verbose
            ${CMAKE_CURRENT_BINARY_DIR}/$(CONFIGURATION)$(EFFECTIVE_PLATFORM_NAME)/${_target}.app/Frameworks/NativeScript.framework
            --sign \"$(EXPANDED_CODE_SIGN_IDENTITY)\"
        )

    endif()

    set_target_properties(${_target} PROPERTIES
        MACOSX_BUNDLE YES
        MACOSX_BUNDLE_INFO_PLIST "${_plist}"
        RESOURCE "${_resources}"
        XCODE_ATTRIBUTE_CODE_SIGN_IDENTITY "iPhone Developer"
        XCODE_ATTRIBUTE_CLANG_ENABLE_OBJC_ARC "YES"
        XCODE_ATTRIBUTE_GCC_C_LANGUAGE_STANDARD "gnu99"
        XCODE_ATTRIBUTE_DEBUG_INFORMATION_FORMAT[variant=Debug] "DWARF"
        XCODE_ATTRIBUTE_INSTALL_PATH "$DSTROOT"
        XCODE_ATTRIBUTE_SKIP_INSTALL "No"
        XCODE_ATTRIBUTE_DEVELOPMENT_TEAM "$ENV{DEVELOPMENT_TEAM}"
        XCODE_ATTRIBUTE_PROVISIONING_PROFILE_SPECIFIER "$ENV{PROVISIONING}"
    )

    if(DEFINED ENV{NATIVESCRIPT_APPLE_DEVELOPMENT_TEAM_ID})
        set_target_properties(${_target} PROPERTIES
            XCODE_ATTRIBUTE_DEVELOPMENT_TEAM "$ENV{NATIVESCRIPT_APPLE_DEVELOPMENT_TEAM_ID}"
        )
    endif()

    include(SetActiveArchitectures)
    SetActiveArchitectures(${_target})

    include(GenerateMetadata)
    GenerateMetadata(${_target})

    add_custom_command(
        TARGET
        ${_target}
        POST_BUILD COMMAND /bin/sh -c
        \"COMMAND_DONE=0 \;
        if ${CMAKE_COMMAND} -E copy_directory
            ${CMAKE_SOURCE_DIR}/MyFrameworks/
            ${PROJECT_BINARY_DIR}/projects/MyApp/\${CONFIGURATION}\${EFFECTIVE_PLATFORM_NAME}/${_target}.app/Frameworks
            \&\>/dev/null \; then
            COMMAND_DONE=1 \;
        fi \;
        #if ${CMAKE_COMMAND} -E copy_directory
        #    \${BUILT_PRODUCTS_DIR}/${FRAMEWORK_NAME}.framework
        #    \${BUILT_PRODUCTS_DIR}/${_target}.app/Frameworks/${FRAMEWORK_NAME}.framework
        #    \&\>/dev/null \; then
        #    COMMAND_DONE=1 \;
        #fi \;
        if [ \\$$COMMAND_DONE -eq 0 ] \; then
            echo Failed to copy the framework into the app bundle \;
            exit 1 \;
        fi\"
    )
endfunction()
