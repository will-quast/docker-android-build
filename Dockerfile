# Pull base image.
FROM ubuntu:16.04

# Install dependencies
RUN \
  export DEBIAN_FRONTEND=noninteractive && \
  apt-get update && \
  apt-get install -y software-properties-common && \
  echo oracle-java8-installer shared/accepted-oracle-license-v1-1 select true | debconf-set-selections && \
  add-apt-repository -y ppa:webupd8team/java && \
  apt-get update && \
  apt-get install -y oracle-java8-installer && \
  apt-get install -y software-properties-common python-software-properties && \
  apt-get install -y bzip2 unzip openssh-client git curl expect build-essential telnet && \
  apt-get install -y libc6-i386 lib32stdc++6 lib32gcc1 lib32ncurses5 lib32z1 libqt5widgets5 && \
  apt-get install -y x11vnc xvfb && \
  apt-get install -y cpu-checker qemu-kvm libvirt-bin ubuntu-vm-builder bridge-utils && \
  rm -rf /var/lib/apt/lists/* && \
  rm -rf /var/cache/oracle-jdk8-installer

# Define commonly used JAVA_HOME variable
ENV JAVA_HOME=/usr/lib/jvm/java-8-oracle

# Setup vnc and set a password
RUN mkdir ~/.vnc && x11vnc -storepasswd 1234 ~/.vnc/passwd

# Define default command.
CMD ["bash"]

# Install Android SDK
RUN wget -nv https://dl.google.com/android/repository/tools_r25.2.3-linux.zip && \
  unzip -q tools_r25.2.3-linux.zip && \
  mkdir /opt/android-sdk-linux && \
  mv tools /opt/android-sdk-linux && \
  rm tools_r25.2.3-linux.zip && \
  (echo y | /opt/android-sdk-linux/tools/bin/sdkmanager "tools") && \
  (echo y | /opt/android-sdk-linux/tools/bin/sdkmanager "platform-tools") && \
  (echo y | /opt/android-sdk-linux/tools/bin/sdkmanager "build-tools;25.0.0" "build-tools;25.0.1" "build-tools;25.0.2") && \
  (echo y | /opt/android-sdk-linux/tools/bin/sdkmanager "platforms;android-24" "platforms;android-25") && \
  (echo y | /opt/android-sdk-linux/tools/bin/sdkmanager "extras;android;m2repository" "extras;google;m2repository") && \
  (echo y | /opt/android-sdk-linux/tools/bin/sdkmanager "extras;google;google_play_services" "extras;google;play_billing") && \
  (echo y | /opt/android-sdk-linux/tools/bin/sdkmanager "ndk-bundle") && \
  (echo y | /opt/android-sdk-linux/tools/android update sdk --no-ui --all --filter sys-img-x86_64-google_apis-24)
  
#  (echo y | /opt/android-sdk-linux/tools/android update sdk --no-ui --all --filter sys-img-armeabi-v7a-google_apis-24)
#  (echo y | /opt/android-sdk-linux/tools/bin/sdkmanager "system-images;android-24;google_apis;armeabi-v7a")

# Install Gradle
RUN wget -nv https://services.gradle.org/distributions/gradle-2.14.1-bin.zip && \
  unzip -q gradle-2.14.1-bin.zip &&\
  mv gradle-2.14.1 /opt/ && \
  rm gradle-2.14.1-bin.zip

# Setup environment variables
ENV ANDROID_SDK_HOME /opt/android-sdk-linux
ENV ANDROID_NDK_HOME /opt/android-ndk-r13b
ENV ANDROID_HOME $ANDROID_SDK_HOME
ENV GRADLE_HOME /opt/gradle-2.14.1
ENV GRADLE_USER_HOME /root/.gradle
ENV PATH $PATH:$ANDROID_SDK_HOME/tools
ENV PATH $PATH:$ANDROID_SDK_HOME/platform-tools
ENV PATH $PATH:$ANDROID_NDK_HOME
ENV PATH $PATH:$GRADLE_HOME/bin
ENV QT_QPA_PLATFORM offscreen
ENV LD_LIBRARY_PATH ${LD_LIBRARY_PATH}:${ANDROID_HOME}/tools/lib64

# Extra tools for the Android Emulator
ADD start-emulator /usr/local/bin/
ADD stop-emulator /usr/local/bin/

# Setup KVM for fast x86 emulation
RUN \
  adduser root kvm && \
  adduser root libvirtd

# Create an Android Virtual Device image for the Android Emulator
RUN android create avd --name avd-android-24 --target android-24 --abi google_apis/x86_64 --device "Nexus 5"

WORKDIR /workspace
