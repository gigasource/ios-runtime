#ifndef NODE_BRIDGE_H_
#define NODE_BRIDGE_H_

typedef void (*t_bridge_callback)(const char* channelName, const char* message);
void RegisterBridgeCallback(t_bridge_callback);
void SendMessageToNodeChannel(const char* channelName, const char* message);
void RegisterNodeDataDirPath(const char* path);

#endif // NODE_BRIDGE_H_
