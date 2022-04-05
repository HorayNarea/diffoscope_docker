FROM debian:sid

LABEL maintainer "Thomas Sänger <thomas@gecko.space>"

ARG DEBIAN_FRONTEND=noninteractive

RUN apt-get update && apt-get dist-upgrade --yes && \
	apt-get install --yes --no-install-recommends \
		build-essential \
		clang \
		cmake \
		devscripts \
		equivs \
		genisoimage \
		git \
		libssl-dev \
		libxml2-dev \
		libxmlb-dev \
		python3-pip \
		radare2 \
		zlib1g-dev && \
	git clone https://salsa.debian.org/reproducible-builds/diffoscope.git /srv/diffoscope && \
	mk-build-deps --install --tool 'apt-get -o Debug::pkgProblemResolver=yes --no-install-recommends --yes' /srv/diffoscope/debian/control && \
	rm -rf /srv/diffoscope/debian && \
	ln -s /usr/lib/x86_64-linux-gnu/xb-tool /usr/local/bin/xb-tool && \
	pip3 --no-cache-dir install defusedxml r2pipe && \
	git clone https://github.com/tpoechtrager/apple-libtapi.git /tmp/apple-libtapi && cd /tmp/apple-libtapi && ./build.sh && ./install.sh && cd / && rm -rf /tmp/apple-libtapi && \
	git clone https://github.com/tpoechtrager/xar.git /tmp/xar && cd /tmp/xar/xar && ./configure && make -j $(nproc) && make install && cd / && rm -rf /tmp/xar && \
	git clone https://github.com/tpoechtrager/cctools-port.git /tmp/cctools-port && cd /tmp/cctools-port/cctools && ./configure && make -j $(nproc) && make install && cd / && rm -rf /tmp/cctools-port && \
#	curl -sSL https://github.com/coreboot/coreboot/archive/refs/tags/4.16.tar.gz | tar xzC /tmp && cd /tmp/coreboot-4.16/util && make -C cbfstool -j $(nproc) && make install -C cbfstool && cd / && rm -rf /tmp/coreboot-4.16 && \
	apt-get remove --purge --yes \
		build-essential \
		clang \
		cmake \
		devscripts \
		equivs \
		git \
		python3-pip && \
	apt-get clean && \
	rm -rf /var/lib/apt/lists/*

RUN useradd -ms /bin/bash user
USER user
WORKDIR /home/user

ENV PATH="/srv/diffoscope/bin:${PATH}"

ENTRYPOINT ["/srv/diffoscope/bin/diffoscope"]
