#include <flutter/plugin_registrar_windows.h>
#include <flutter/standard_method_codec.h>
#include <windows.h>
#include <commdlg.h>
#include <memory>
#include <string>

namespace
{

    class FilePickerPlugin : public flutter::Plugin
    {
    public:
        static void RegisterWithRegistrar(flutter::PluginRegistrarWindows *registrar);

        FilePickerPlugin();

        virtual ~FilePickerPlugin();

    private:
        void HandleMethodCall(
            const flutter::MethodCall<flutter::EncodableValue> &method_call,
            std::unique_ptr<flutter::MethodResult<flutter::EncodableValue>> result);
    };

    void FilePickerPlugin::RegisterWithRegistrar(
        flutter::PluginRegistrarWindows *registrar)
    {
        auto channel =
            std::make_unique<flutter::MethodChannel<flutter::EncodableValue>>(
                registrar->messenger(), "miguelruivo.flutter.plugins.filepicker",
                &flutter::StandardMethodCodec::GetInstance());

        auto plugin = std::make_unique<FilePickerPlugin>();

        channel->SetMethodCallHandler(
            [plugin_pointer = plugin.get()](const auto &call, auto result)
            {
                plugin_pointer->HandleMethodCall(call, std::move(result));
            });

        registrar->AddPlugin(std::move(plugin));
    }

    FilePickerPlugin::FilePickerPlugin() {}

    FilePickerPlugin::~FilePickerPlugin() {}

    void FilePickerPlugin::HandleMethodCall(
        const flutter::MethodCall<flutter::EncodableValue> &method_call,
        std::unique_ptr<flutter::MethodResult<flutter::EncodableValue>> result)
    {
        if (method_call.method_name().compare("audio") == 0)
        {
            OPENFILENAME ofn;
            char szFile[260] = {0};
            ZeroMemory(&ofn, sizeof(ofn));
            ofn.lStructSize = sizeof(ofn);
            ofn.hwndOwner = NULL;
            ofn.lpstrFile = szFile;
            ofn.nMaxFile = sizeof(szFile);
            ofn.lpstrFilter = "Audio Files\0*.mp3;*.wav;*.flac;*.mov\0All Files\0*.*\0";
            ofn.nFilterIndex = 1;
            ofn.lpstrFileTitle = NULL;
            ofn.nMaxFileTitle = 0;
            ofn.lpstrInitialDir = NULL;
            ofn.Flags = OFN_PATHMUSTEXIST | OFN_FILEMUSTEXIST;

            if (GetOpenFileName(&ofn))
            {
                result->Success(flutter::EncodableValue(std::string(ofn.lpstrFile)));
            }
            else
            {
                result->Error("CANCELLED", "User cancelled the file picker");
            }
        }
        else
        {
            result->NotImplemented();
        }
    }

} // namespace

void FilePickerPluginRegisterWithRegistrar(
    FlutterDesktopPluginRegistrarRef registrar)
{
    FilePickerPlugin::RegisterWithRegistrar(
        flutter::PluginRegistrarManager::GetInstance()
            ->GetRegistrar<flutter::PluginRegistrarWindows>(registrar));
}