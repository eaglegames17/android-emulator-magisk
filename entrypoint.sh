#!/bin/bash

# Wait for Android emulator to fully boot
echo "Waiting for emulator to be ready..."
adb wait-for-device
sleep 10  # just to be extra sure it's stable

# Install Xposed and app APKs
for apk in /root/tmp/xposed/*.apk /root/tmp/apps/*.apk; do
    if [ -f "$apk" ]; then
        echo "Installing $apk..."
        adb install -r "$apk"
    fi
done

# Optional: Run your Appium test
echo "Running Appium Python test..."
python3 /root/appium_test.py

# Keep the container alive (optional for debugging)
tail -f /dev/null
