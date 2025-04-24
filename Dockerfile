FROM budtmo/docker-android:emulator_13.0_v2.1.3-p1

# Install Python and required tools
USER root
RUN apt-get update && \
    apt-get install -y python3-pip && \
    pip3 install --upgrade pip

# Copy Python automation script and install dependencies
COPY requirements.txt /tmp/
RUN pip3 install -r /tmp/requirements.txt

# Copy APKs and Python script
COPY xposed/ /root/tmp/xposed/
COPY apps/ /root/tmp/apps/
COPY appium_test.py /root/appium_test.py

# Copy entrypoint script
COPY entrypoint.sh /entrypoint.sh
RUN chmod +x /entrypoint.sh

ENTRYPOINT ["/entrypoint.sh"]
