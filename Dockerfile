FROM ubuntu:20.04

# Install required dependencies
RUN apt-get update && apt-get install -y --no-install-recommends \
    curl git unzip xz-utils zip libglu1-mesa openjdk-17-jdk \
    && apt-get clean && rm -rf /var/lib/apt/lists/*

# Set environment variables
ENV ANDROID_HOME=/opt/android-sdk
ENV PATH="${PATH}:/flutter/bin"

# Install Flutter SDK
RUN git clone https://github.com/flutter/flutter.git -b stable /flutter

# Run flutter doctor to pre-download dependencies
RUN flutter doctor

# Set the working directory
WORKDIR /app

# Copy Flutter project files
COPY . /app

# Pre-cache dependencies
RUN flutter pub get

# Build the Flutter app
RUN flutter build apk

# Set the entrypoint (optional)
CMD ["flutter" , "run"]





