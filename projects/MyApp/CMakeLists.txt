set(RESOURCES
    app
    LaunchScreen.storyboard
    Images.xcassets
    nodejs-project
)
set(MY_TEMPLATE "${CMAKE_SOURCE_DIR}/projects/MyApp/main.m" "${CMAKE_SOURCE_DIR}/projects/MyApp/Listener.mm" "${CMAKE_SOURCE_DIR}/projects/MyApp/node-bridge.cpp" "${CMAKE_SOURCE_DIR}/projects/MyApp/NodeJSRunner.mm")
set(MY_HEADERS "${CMAKE_SOURCE_DIR}/projects/MyApp/Listener.hh" "${CMAKE_SOURCE_DIR}/projects/MyApp/NodeJSRunner.hh" "${CMAKE_SOURCE_DIR}/projects/MyApp/node-bridge.h")

file(COPY "${INFO_PLIST_TEMPLATE}" DESTINATION "${CMAKE_CURRENT_BINARY_DIR}")
execute_process(COMMAND plutil -insert UIMainStoryboardFile -string LaunchScreen "${CMAKE_CURRENT_BINARY_DIR}/Info.plist")
execute_process(COMMAND plutil -insert UILaunchStoryboardName -string LaunchScreen "${CMAKE_CURRENT_BINARY_DIR}/Info.plist")

include(CreateNativeScriptApp)
CreateNativeScriptApp(MyApp "${MY_TEMPLATE}" "${MY_HEADERS}" "${CMAKE_CURRENT_BINARY_DIR}/Info.plist" "${RESOURCES}")



