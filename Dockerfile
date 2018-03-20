FROM debian:stretch

ARG PKG=https://go.microsoft.com/fwlink/?LinkID=760868
ARG APT_ARGS="-fy --no-install-recommends"
ARG CLEANUP=/etc/apt/cleanup.sh
ARG DEPS="git \
	libcanberra-gtk-module \
	libxext-dev \
	libxrender-dev \
	libx11-xcb1 \
	libxss1 \
	libxtst-dev \
	packagekit-gtk3-module \
	php-cli"

RUN echo 'debconf debconf/frontend select Noninteractive' | debconf-set-selections \
	&& echo '#!/bin/sh' > ${CLEANUP} \
	&& echo 'apt-get autoremove -y' >> ${CLEANUP} \
	&& echo 'apt-get clean' >> ${CLEANUP} \
	&& echo 'apt-get autoclean' >> ${CLEANUP} \
	&& echo 'rm -frv /tmp/*' >> ${CLEANUP} \
	&& chmod +x -v ${CLEANUP} \
	&& apt-get update --fix-missing \
	&& apt-get install ${APT_ARGS} \
		apt-utils \
		sudo \
		wget \
	&& ${CLEANUP}

RUN wget -qO /tmp/pkg.deb \
		--no-check-certificate \
		--show-progress \
		${PKG} \
	&& apt-get install ${APT_ARGS} \
		${DEPS} \
		/tmp/pkg.deb \
	&& ${CLEANUP}

ARG USERNAME=developer
ARG UID=1000
ARG GID=1000

RUN mkdir -pv /home/${USERNAME} \
	&& rm -frv /root \
	&& ln -fsv /home/${USERNAME} /root \
	&& groupadd ${USERNAME} -g ${GID} \
	&& useradd -r \
		-d /home/${USERNAME} \
		-u ${UID} \
		-g ${GID} \
		${USERNAME} \
		-s /bin/bash \
	&& echo "${USERNAME} ALL=(ALL) NOPASSWD:ALL" > /etc/sudoers.d/${USERNAME} \
	&& chown -Rv ${USERNAME} /home/${USERNAME}

USER ${USERNAME}

ENTRYPOINT ["/usr/bin/code", "--verbose"]

# docker run --rm -it \
#	-v /tmp/.X11-unix:/tmp/.X11-unix \
#	-e DISPLAY=$DISPLAY \
