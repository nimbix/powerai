FROM ibmcom/powerai:1.6.0-all-ubuntu18.04-py3

# prevent build pipelines from breaking if older CUDA installed on build box
ENV DOCKER_NVIDIA_REQUIRE_CUDA ${NVIDIA_REQUIRE_CUDA}
ENV NVIDIA_REQUIRE_CUDA ""

# Nimbix bits and Nimbix desktop
RUN curl -H 'Cache-Control: no-cache' \
    https://raw.githubusercontent.com/nimbix/image-common/master/install-nimbix.sh \
    | bash
EXPOSE 22
EXPOSE 5901
EXPOSE 443

# EULA from base image
ADD https://raw.githubusercontent.com/IBM/powerai/powerai-1.6.0/dockerhub/LICENSE /etc/EULA.txt
RUN echo "-----------------------------------------------" >>/etc/EULA.txt
RUN echo "For the Anaconda End User License Agreement, please visit:" >> EULA.txt
RUN echo "  http://docs.anaconda.com/anaconda/eula/" >> EULA.txt
RUN mkdir -p /etc/NAE && cp -f /etc/EULA.txt /etc/NAE/license.txt

# samples
RUN mkdir -p /usr/local/samples
ADD JM.tar.gz /usr/local/samples

# anaconda helpers
COPY conda /usr/bin
COPY conda-activate.sh /etc/profile.d/conda-activate.sh

# motd
COPY motd /etc/motd

# AppDef
COPY AppDef.json /etc/NAE/AppDef.json
RUN curl --fail -X POST -d @/etc/NAE/AppDef.json https://api.jarvice.com/jarvice/validate

# Material Compute screenshot
COPY screenshot.png /etc/NAE/screenshot.png

# restore CUDA requirement
ENV NVIDIA_REQUIRE_CUDA ${DOCKER_NVIDIA_REQUIRE_CUDA}
ENV DOCKER_NVIDIA_REQUIRE_CUDA ""
