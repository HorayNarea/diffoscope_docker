FROM debian:bookworm-slim

LABEL maintainer="Thomas Sänger <thomas@gecko.space>"

ENV DIFFOSCOPE_VERSION=284
ENV COREBOOT_VERSION=24.08

ARG DEBIAN_FRONTEND=noninteractive

RUN apt-get update && apt-get dist-upgrade --yes && \
	apt-get install --yes --no-install-recommends \
		apktool \
		build-essential \
		clang \
		cmake \
		curl \
		devscripts \
		equivs \
		genisoimage \
		git \
		libssl-dev \
		libxml2-dev \
		libxmlb-dev \
		ninja-build \
		python3-pip \
		wget \
		zlib1g-dev && \
	git clone https://github.com/radareorg/radare2.git /opt/radare2 && /opt/radare2/sys/install.sh && \
	curl -sSL https://salsa.debian.org/reproducible-builds/diffoscope/-/archive/${DIFFOSCOPE_VERSION}/diffoscope-${DIFFOSCOPE_VERSION}.tar.gz | tar xzC /opt && ln -sv /opt/diffoscope-${DIFFOSCOPE_VERSION} /opt/diffoscope && \
	mk-build-deps --install --tool 'apt-get -o Debug::pkgProblemResolver=yes --no-install-recommends --yes' /opt/diffoscope/debian/control && \
	rm -rf /opt/diffoscope/debian && \
	ln -s /usr/lib/x86_64-linux-gnu/xb-tool /usr/local/bin/xb-tool && \
	pip3 --no-cache-dir install --break-system-packages defusedxml r2pipe && \
	git clone https://github.com/tpoechtrager/apple-libtapi.git /tmp/apple-libtapi && cd /tmp/apple-libtapi && ./build.sh && ./install.sh && cd / && rm -rf /tmp/apple-libtapi && \
	git clone https://github.com/tpoechtrager/xar.git /tmp/xar && cd /tmp/xar/xar && ./configure && make -j $(nproc) && make install && cd / && rm -rf /tmp/xar && \
	git clone https://github.com/tpoechtrager/apple-libdispatch.git /tmp/libdispatch && cd /tmp/libdispatch && cmake -G Ninja -DCMAKE_C_COMPILER=clang -DCMAKE_CXX_COMPILER=clang++ . && ninja && ninja install && cd / && rm -rf /tmp/libdispatch && \
	git clone https://github.com/tpoechtrager/cctools-port.git /tmp/cctools-port && cd /tmp/cctools-port/cctools && ./configure && make -j $(nproc) && make install && cd / && rm -rf /tmp/cctools-port && \
		rm /usr/local/bin/ar && \
		rm /usr/local/bin/as && \
		rm /usr/local/bin/ld && \
		rm /usr/local/bin/nm && \
		rm /usr/local/bin/ranlib && \
		rm /usr/local/bin/size && \
		rm /usr/local/bin/strings && \
		rm /usr/local/bin/strip && \
	curl -sSL https://coreboot.org/releases/coreboot-${COREBOOT_VERSION}.tar.xz | tar xJC /tmp && cd /tmp/coreboot-${COREBOOT_VERSION}/util && make -C cbfstool -j $(nproc) && make install -C cbfstool && cd / && rm -rf /tmp/coreboot-${COREBOOT_VERSION} && \
	apt-get remove --purge --yes \
		build-essential \
		clang \
		cmake \
		curl \
		devscripts \
		equivs \
		git \
		ninja-build \
		python3-pip \
		wget && \
	apt-get clean && \
	rm -rf /var/lib/apt/lists/*

RUN useradd -ms /bin/bash user
USER user
WORKDIR /home/user

ENV PATH="/opt/diffoscope/bin:${PATH}"

ENTRYPOINT ["/opt/diffoscope/bin/diffoscope"]
