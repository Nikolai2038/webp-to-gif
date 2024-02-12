FROM debian:bookworm-20240130-slim

# Update system and install necessary packages
RUN apt update && apt install -y \
  # Dependencies from here: https://chromium.googlesource.com/webm/libwebp/+/HEAD/doc/building.md
  gcc make autoconf automake libtool \
  # Install various support for image formats (also to fix warnings while running ./configure)
  libpng-dev libjpeg-dev libgif-dev libwebp-dev libtiff-dev libsdl2-dev \
  # To clone libwebp repository
  git \
  # For conversion from PNGs to GIF
  ffmpeg \
  # For GIF compression
  gifsicle

# ========================================
# Installation
# (Based on: https://askubuntu.com/a/1141049)
# ========================================
WORKDIR /app
RUN git clone https://chromium.googlesource.com/webm/libwebp
WORKDIR /app/libwebp
RUN echo "bin_PROGRAMS += anim_dump" >> ./examples/Makefile.am

RUN ./autogen.sh
RUN ./configure

# Require no warnings
RUN if grep --ignore-case 'warn' ./configure.log; then exit 1; fi

RUN make
# Installed utilities are in /usr/local/bin: anim_dump cwebp dwebp gif2webp img2webp webpinfo webpmux
RUN make install

# See: https://stackoverflow.com/questions/12045563/cannot-load-shared-library-that-exists-in-usr-local-lib-fedora-x64/12057372#12057372
RUN echo "/usr/local/lib" >> /etc/ld.so.conf
RUN ldconfig

# Check installation
RUN webpinfo -version
RUN anim_dump -version
# ========================================

# ========================================
# Clear
# ========================================
# Remove build files
RUN rm -rf /app/libwebp

# Clear APT cache to make docker image smaller
RUN apt-get autoremove -y && apt-get clean && rm -rf /var/lib/apt/lists/*
# ========================================

WORKDIR /app
# Copy all scripts to the container
COPY ./*.sh ./

# To make container work in the background
ENTRYPOINT ["tail", "-f", "/dev/null"]
