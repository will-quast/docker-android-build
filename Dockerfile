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
  apt-get install -y cpu-checker qemu-kvm libvirt-bin ubuntu-vm-builder bridge-utils && \
  rm -rf /var/lib/apt/lists/* && \
  rm -rf /var/cache/oracle-jdk8-installer

# Define commonly used JAVA_HOME variable
ENV JAVA_HOME=/usr/lib/jvm/java-8-oracle

# Define default command.
CMD ["bash"]

# Install Android SDK
RUN \
  wget -nv https://dl.google.com/android/repository/sdk-tools-linux-3859397.zip && \
  unzip -q sdk-tools-linux-3859397.zip && \
  mkdir /opt/android-sdk-linux && \
  mv tools /opt/android-sdk-linux && \
  rm sdk-tools-linux-3859397.zip && \
  (echo y | /opt/android-sdk-linux/tools/bin/sdkmanager "tools") && \
  (echo y | /opt/android-sdk-linux/tools/bin/sdkmanager "platform-tools") && \
  (echo y | /opt/android-sdk-linux/tools/bin/sdkmanager "build-tools;26.0.1" "build-tools;27.0.1" "build-tools;27.0.3") && \
  (echo y | /opt/android-sdk-linux/tools/bin/sdkmanager "platforms;android-26" "platforms;android-27") && \
  (echo y | /opt/android-sdk-linux/tools/bin/sdkmanager "extras;android;m2repository" "extras;google;m2repository") && \
  (echo y | /opt/android-sdk-linux/tools/bin/sdkmanager "ndk-bundle") && \
  (echo y | /opt/android-sdk-linux/tools/bin/sdkmanager "emulator") && \
  (echo y | /opt/android-sdk-linux/tools/bin/sdkmanager "system-images;android-24;google_apis;x86_64")

# Install Gradle
RUN \
  wget -nv https\://services.gradle.org/distributions/gradle-4.1-all.zip && \
  unzip -q gradle-4.1-all.zip &&\
  mv gradle-4.1 /opt/ && \
  rm gradle-4.1-all.zip

# Setup environment variables
ENV ANDROID_SDK_HOME /opt/android-sdk-linux
ENV ANDROID_NDK_HOME $ANDROID_SDK_HOME/ndk-bundle
ENV ANDROID_HOME $ANDROID_SDK_HOME
ENV GRADLE_HOME /opt/gradle-4.1
ENV GRADLE_USER_HOME /root/.gradle
ENV PATH $PATH:$ANDROID_SDK_HOME/tools
ENV PATH $PATH:$ANDROID_SDK_HOME/tools/bin
ENV PATH $PATH:$ANDROID_SDK_HOME/platform-tools
ENV PATH $PATH:$ANDROID_SDK_HOME/emulator
ENV PATH $PATH:$ANDROID_NDK_HOME
ENV PATH $PATH:$GRADLE_HOME/bin
ENV QT_QPA_PLATFORM offscreen
ENV LD_LIBRARY_PATH ${LD_LIBRARY_PATH}:${ANDROID_HOME}/emulator/lib64/qt/lib

# Extra tools for the Android Emulator
ADD start-emulator /usr/local/bin/
ADD stop-emulator /usr/local/bin/

# Setup KVM for fast x86 emulation
RUN \
  adduser root kvm && \
  adduser root libvirtd

# Create an Android Virtual Device image for the Android Emulator
#TODO: avd is not currently used for tests so dont create one...
#RUN avdmanager create avd --name avd-android-24 --package "system-images;android-24;google_apis;x86_64" --tag "google_apis" --device "Nexus 5"

WORKDIR /workspace

