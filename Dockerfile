FROM debian:trixie

ENV DEBIAN_FRONTEND=noninteractive

# Install build tools and GStreamer dependencies
RUN apt-get update && apt-get install -y \
    git git-lfs ca-certificates \
    build-essential pkg-config \
    autoconf automake libtool autopoint gettext gtk-doc-tools \
    bison flex \
    libglib2.0-dev \
    libgstreamer1.0-dev \
    libgstreamer-plugins-base1.0-dev \
    gstreamer1.0-tools \
    gstreamer1.0-plugins-base \
    gstreamer1.0-plugins-good \
    gstreamer1.0-plugins-bad \
    gstreamer1.0-plugins-ugly \
    gstreamer1.0-libav \
    libssl-dev libpcap-dev \
    python3 python3-pip \
    gdb valgrind tcpdump iproute2 iputils-ping net-tools \
    && rm -rf /var/lib/apt/lists/*

# Working directory
WORKDIR /opt

# Download gst-mprtp source code
RUN git clone --recursive https://github.com/balazskreith/gst-mprtp.git

WORKDIR /opt/gst-mprtp

# Generate configure script
RUN ./autogen.sh --noconfigure

# Configure build
RUN CFLAGS="-Wno-error -Wno-address-of-packed-member" ./configure \
    --prefix=/usr/local \
    --libdir=/usr/local/lib/x86_64-linux-gnu

# Compile and install
RUN make -j$(nproc) CFLAGS="-Wno-error -Wno-address-of-packed-member"
RUN make install

# Manually install GStreamer plugin
RUN mkdir -p /usr/local/lib/gstreamer-1.0 && \
    cp /opt/gst-mprtp/plugins/.libs/libgstmprtp.so /usr/local/lib/gstreamer-1.0/ && \
    chmod 755 /usr/local/lib/gstreamer-1.0/libgstmprtp.so

RUN ldconfig

# Tell GStreamer where to find custom plugin
ENV GST_PLUGIN_PATH=/usr/local/lib/gstreamer-1.0
ENV GST_DEBUG=2

CMD ["bash"]
