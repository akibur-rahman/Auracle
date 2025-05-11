#ifndef FILE_PICKER_PLUGIN_H_
#define FILE_PICKER_PLUGIN_H_

#include <flutter_plugin_registrar.h>

#ifdef FLUTTER_PLUGIN_IMPL
#define FLUTTER_PLUGIN_EXPORT __declspec(dllexport)
#else
#define FLUTTER_PLUGIN_EXPORT __declspec(dllimport)
#endif

#if defined(__cplusplus)
extern "C"
{
#endif

    FLUTTER_PLUGIN_EXPORT void FilePickerPluginRegisterWithRegistrar(
        FlutterDesktopPluginRegistrarRef registrar);

#if defined(__cplusplus)
} // extern "C"
#endif

#endif // FILE_PICKER_PLUGIN_H_