FROM ubuntu:20.04

ENV ANDROID_HOME /opt/android-sdk
ENV PATH $PATH:$ANDROID_HOME/cmdline-tools/latest/bin:$ANDROID_HOME/emulator:$ANDROID_HOME/platform-tools
ENV DEBIAN_FRONTEND=noninteractive

# Install dependencies
RUN apt-get update && apt-get install -y \
    openjdk-11-jdk wget unzip curl git libgl1-mesa-dev \
    qemu-kvm libvirt-clients libvirt-daemon-system bridge-utils \
    python3 python3-pip zip sudo net-tools \
    build-essential libssl-dev && \
    rm -rf /var/lib/apt/lists/*

# Install Node.js and Appium
RUN curl -fsSL https://deb.nodesource.com/setup_18.x | bash - && \
    apt-get install -y nodejs && \
    npm install -g appium appium-doctor

# Install Android command-line tools (cleaned up)
RUN mkdir -p ${ANDROID_HOME}/cmdline-tools && \
    cd ${ANDROID_HOME}/cmdline-tools && \
    wget https://dl.google.com/android/repository/commandlinetools-linux-9477386_latest.zip -O tools.zip && \
    unzip tools.zip -d temp && \
    mv temp/cmdline-tools ${ANDROID_HOME}/cmdline-tools/latest

# Install Android packages
RUN yes | sdkmanager --sdk_root=${ANDROID_HOME} \
    "emulator" "platform-tools" "platforms;android-30" "system-images;android-30;google_apis;x86_64"

# Create AVD
RUN echo "no" | avdmanager create avd -n magisk-avd \
    -k "system-images;android-30;google_apis;x86_64" --device "pixel"

# Clone pre-rooted image
RUN git clone https://github.com/Revanced-Magisk-Modules/emulator-magisk /magisk-emulator && \
    cp -r /magisk-emulator/system-images/* ${ANDROID_HOME}/system-images/android-30/google_apis/x86_64/

# Download LSPosed and Device Faker modules
RUN mkdir -p /modules && \
    wget https://github.com/LSPosed/LSPosed/releases/latest/download/LSPosed-v1.9.2-6726-zygisk-release.zip -O /modules/lsposed.zip && \
    wget https://github.com/superyujin/device-faker/releases/latest/download/devicefaker.zip -O /modules/devicefaker.zip

# Install modules to Magisk directory
RUN mkdir -p /data/adb/modules/lsposed && \
    unzip /modules/lsposed.zip -d /data/adb/modules/lsposed && \
    touch /data/adb/modules/lsposed/enable

RUN mkdir -p /data/adb/modules/devicefaker && \
    unzip /modules/devicefaker.zip -d /data/adb/modules/devicefaker && \
    touch /data/adb/modules/devicefaker/enable

# Expose emulator & Appium ports
EXPOSE 5554 5555 4723

# Start emulator + Appium together
CMD bash -c "\
emulator -avd magisk-avd -writable-system -no-audio -no-window -gpu swiftshader_indirect -qemu -m 2048 & \
sleep 40 && \
appium --address 0.0.0.0 --port 4723"
