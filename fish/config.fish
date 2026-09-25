source /usr/share/cachyos-fish-config/cachyos-config.fish

# overwrite greeting
# potentially disabling fastfetch
#function fish_greeting
#    # smth smth
#end


# DOTNET
export DOTNET_ROOT="$HOME/.dotnet"
export PATH="$PATH:$HOME/.dotnet"
export PATH="$PATH:$HOME/.dotnet/tools"
export SSL_CERT_DIR="$HOME/.aspnet/dev-certs/trust:/etc/ssl/certs"


# ANDROID SDK / Expo
set -gx ANDROID_HOME "$HOME/Android/Sdk"
set -gx ANDROID_SDK_ROOT "$ANDROID_HOME"

fish_add_path "$ANDROID_HOME/platform-tools"
fish_add_path "$ANDROID_HOME/emulator"
fish_add_path "$ANDROID_HOME/tools"
fish_add_path "$ANDROID_HOME/tools/bin"


# SETUP SSH KEYCHAIN
if command -v keychain >/dev/null 2>&1
    eval (keychain --eval --quiet \
        ~/.ssh/id_priv_github \
        ~/.ssh/htz_paturo_servers)
end



# opencode
fish_add_path /home/hoejsagerc/.opencode/bin

# opencode
fish_add_path /home/christian/.opencode/bin
