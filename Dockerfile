FROM ubuntu:22.04
LABEL maintainer="kuloud(xkuloud@gmail.com)"

# Prerequisites
RUN apt update && apt install -y curl git unzip xz-utils zip libglu1-mesa openjdk-17-jdk wget clang cmake ninja-build pkg-config

# Set up new user
RUN useradd -ms /bin/bash developer
USER developer
WORKDIR /home/developer

# Prepare Android directories and system variables
RUN mkdir -p Android/sdk/cmdline-tools
ENV ANDROID_SDK_ROOT /home/developer/Android/sdk
ENV ANDROID_HOME /home/developer/Android/sdk
RUN mkdir -p .android && touch .android/repositories.cfg

# Set up Android SDK
ARG ANDROID_SDK_TOOLS="11076708"
RUN wget -O commandlinetools.zip https://dl.google.com/android/repository/commandlinetools-linux-${ANDROID_SDK_TOOLS}_latest.zip
RUN unzip commandlinetools.zip && rm commandlinetools.zip
RUN mv cmdline-tools Android/sdk/cmdline-tools/latest
RUN cd Android/sdk/cmdline-tools/latest/bin && yes | ./sdkmanager --licenses
# "build-tools;34.0.0" "patcher;v4" "sources;android-34"
RUN cd Android/sdk/cmdline-tools/latest/bin && ./sdkmanager "platform-tools" "platforms;android-34" 
ENV PATH "$PATH:/home/developer/Android/sdk/platform-tools"

# Download Flutter SDK
RUN git clone https://github.com/flutter/flutter.git
ENV PATH "$PATH:/home/developer/flutter/bin"
RUN git config --global --add safe.directory /home/developer/flutter

# ENV AAPT_HOME "/home/developer/Android/sdk/build-tools/34.0.0"

# ENV PATH=$PATH:$AAPT_HOME

ENV FLUTTER_ROOT="/home/developer/flutter"

### Add flutter executable to path
ENV PATH="${PATH}:${FLUTTER_ROOT}/bin"

### Make it easy to use other Dart and Pub packages
ENV DART_SDK="${FLUTTER_ROOT}/bin/cache/dart-sdk"
ENV PUB_CACHE=${FLUTTER_ROOT}/.pub-cache
ENV PATH="${PATH}:${DART_SDK}/bin:${PUB_CACHE}/bin"

RUN flutter config --android-sdk /home/developer/Android/sdk/

# Run basic check to download Dark SDK
RUN flutter doctor
