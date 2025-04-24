FROM ubuntu:22.04

ENV DEBIAN_FRONTEND=noninteractive
ENV ANDROID_SDK_ROOT=/opt/android-sdk
ENV PATH="$ANDROID_SDK_ROOT/cmdline-tools/latest/bin:$ANDROID_SDK_ROOT/platform-tools:$PATH"

# --- Install dependencies ---
RUN apt-get update && apt-get install -y \
    wget unzip git curl sudo libgl1-mesa-dev libvirt-daemon-system qemu-kvm \
    openjdk-11-jdk android-sdk adb xz-utils nodejs npm

# --- Install Android SDK Command Line Tools ---
RUN mkdir -p $ANDROID_SDK_ROOT/cmdline-tools && \
    cd $ANDROID_SDK_ROOT/cmdline-tools && \
    wget https://dl.google.com/android/repository/commandlinetools-linux-11076708_latest.zip -O cmdline-tools.zip && \
    unzip cmdline-tools.zip && rm cmdline-tools.zip && \
    mv cmdline-tools latest

# --- Accept licenses and install packages ---
RUN yes | sdkmanager --licenses && \
    sdkmanager \
        "platform-tools" \
        "emulator" \
        "platforms;android-30" \
        "system-images;android-30;google_apis;x86_64"

# --- Create AVD ---
RUN echo "no" | avdmanager create avd -n magisk-avd \
    -k "system-images;android-30;google_apis;x86_64" --device "pixel"

# --- Replace system.img with pre-rooted Magisk image ---
RUN mkdir -p /root/magisk-image && \
    wget -O /root/magisk-image/system.img.xz https://github.com/thepacketgeek/android-magisk-emulator/releases/download/v1.0/system.img.xz && \
    unxz /root/magisk-image/system.img.xz && \
    mv /root/magisk-image/system.img $ANDROID_SDK_ROOT/system-images/android-30/google_apis/x86_64/

# --- Install Appium ---
RUN npm install -g appium

# --- Expose ports: 5555 for ADB, 4723 for Appium ---
EXPOSE 5555 4723

# --- Run emulator and Appium ---
CMD bash -c "\
emulator -avd magisk-avd -writable-system -no-audio -no-window -gpu swiftshader_indirect -qemu -m 2048 & \
sleep 40 && \
appium --address 0.0.0.0 --port 4723"
