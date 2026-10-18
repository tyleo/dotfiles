eval "$(/opt/homebrew/bin/brew shellenv)"

# Only exported when `java_home` finds a JDK.
JAVA_HOME="$(/usr/libexec/java_home 2>/dev/null)" && export JAVA_HOME
export ANDROID_HOME="$HOME/Library/Android/sdk"
# After `brew shellenv` so the SDK's `adb` shadows any other.
export PATH="$ANDROID_HOME/platform-tools:$PATH"
