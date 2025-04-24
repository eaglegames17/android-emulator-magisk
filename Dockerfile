FROM budtmo/docker-android:emulator_13.0_v2.1.3-p1

USER root

# Install Python and Appium
RUN apt update && \
    apt install -y python3 python3-pip unzip wget && \
    pip3 install Appium-Python-Client

# Install APKs: Xposed Installer, Device Faker, and your app
COPY ./apps /root/tmp/apps
COPY ./xposed /root/tmp/xposed

# Install user APKs and tools
RUN for apk in /root/tmp/xposed/*.apk /root/tmp/apps/*.apk; do \
      [ -f "$apk" ] && adb install "$apk"; \
    done

# Enable Device Faker Xposed module (simulate activation)
RUN adb shell su -c "mkdir -p /data/data/de.robv.android.xposed.installer/conf" && \
    adb shell su -c "echo 'com.devicefaker.module' > /data/data/de.robv.android.xposed.installer/conf/modules.list"

# Trigger soft reboot (required after activating Xposed modules)
RUN adb shell su -c "setprop ctl.restart zygote"

# Allow time for reboot
RUN sleep 20
