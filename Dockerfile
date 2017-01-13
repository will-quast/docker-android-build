# Pull base image.
FROM ubuntu:16.04

# Install dependencies
RUN \
  apt-get update && \
  apt-get install -y software-properties-common && \
  echo oracle-java8-installer shared/accepted-oracle-license-v1-1 select true | debconf-set-selections && \
  add-apt-repository -y ppa:webupd8team/java && \
  apt-get update && \
  apt-get install -y oracle-java8-installer && \
  apt-get install -y software-properties-common python-software-properties && \
  apt-get install -y bzip2 unzip openssh-client git curl expect build-essential && \
  apt-get install -y libc6-i386 lib32stdc++6 lib32gcc1 lib32ncurses5 lib32z1 && \
  apt-get install -y x11vnc xvfb && \
  rm -rf /var/lib/apt/lists/* && \
  rm -rf /var/cache/oracle-jdk8-installer

# Define commonly used JAVA_HOME variable
ENV JAVA_HOME=/usr/lib/jvm/java-8-oracle

# Setup vnc and set a password
RUN mkdir ~/.vnc && x11vnc -storepasswd 1234 ~/.vnc/passwd

# Define display x11 server to use TCP for emulator
#ENV DISPLAY=localhost:0

# Define default command.
CMD ["bash"]

# Install android-sdk studio and all packages
#RUN useradd -ms /bin/bash worker
#USER worker
#WORKDIR /home/worker

ADD scripts/accept-licenses /usr/local/bin/
ADD scripts/start-emulator /usr/local/bin/

# Install Android SDK
RUN wget -nv http://dl.google.com/android/android-sdk_r24.4.1-linux.tgz && \
  tar -xzf android-sdk_r24.4.1-linux.tgz  -C /opt && \
  rm android-sdk_r24.4.1-linux.tgz
  
# Install Android NDK
RUN wget -nv https://dl.google.com/android/repository/android-ndk-r13b-linux-x86_64.zip && \
  unzip -q android-ndk-r13b-linux-x86_64.zip && \
  mv android-ndk-r13b /opt/ && \
  rm android-ndk-r13b-linux-x86_64.zip

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

# Update Android sdk
RUN accept-licenses "android update sdk --no-ui --all --filter \
tools,platform-tools,\
build-tools-25.0.0,build-tools-25.0.1,build-tools-25.0.2,\
android-24,android-25,\
extra-android-m2repository,extra-google-m2repository,\
extra-google-google_play_services,extra-google-play_billing,\
sys-img-armeabi-v7a-google_apis-24,sys-img-armeabi-v7a-google_apis-25" \
"android-sdk-preview-license-d099d938|android-sdk-license-c81a61d9"

COPY licenses/ licenses/
RUN mv licenses $ANDROID_HOME/

RUN android create avd --name test_avd --target android-24 --abi google_apis/armeabi-v7a --device "Nexus 5" --snapshot
# emulator64-arm -no-window -no-skin -no-audio -avd test_avd -port 5554 &

WORKDIR /workspace
