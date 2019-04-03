FROM ibmcom/powerai:1.6.0-all-ubuntu18.04

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
ADD https://raw.githubusercontent.com/IBM/powerai/powerai-1.6.0/dockerhub/LICENSE /etc/EULA-unicode.txt
RUN iconv -f unicode -t utf8 /etc/EULA-unicode.txt >/etc/EULA.txt
RUN echo "-----------------------------------------------" >>/etc/EULA.txt
RUN echo "For the Anaconda End User License Agreement, please visit:" >> EULA.txt
RUN echo "  http://docs.anaconda.com/anaconda/eula/" >> EULA.txt
RUN mkdir -p /etc/NAE && cp /etc/EULA.txt /etc/NAE/license.txt && chmod 0644 /etc/EULA.txt

# anaconda helpers
RUN cp -f ${CONDA_INSTALL_DIR}/etc/profile.d/conda.sh /etc/profile.d
COPY conda /usr/bin/conda

# install notebook
RUN conda install -y jupyter && conda clean --all
RUN apt-get update && apt-get -y install redir && apt-get clean
RUN chmod 04555 /usr/bin/redir

# samples
RUN mkdir -p /usr/local/notebook/samples
ADD JM.tar.gz /usr/local/notebook/samples
RUN chmod -R a+w /usr/local/notebook/samples
RUN ln -s /data /usr/local/notebook/data

# notebook script
COPY notebook.sh /usr/local/bin/notebook.sh

# AppDef
COPY AppDef.json /etc/NAE/AppDef.json
RUN curl --fail -X POST -d @/etc/NAE/AppDef.json https://api.jarvice.com/jarvice/validate

# Material Compute screenshot
COPY screenshot.png /etc/NAE/screenshot.png

# restore CUDA requirement
ENV NVIDIA_REQUIRE_CUDA ${DOCKER_NVIDIA_REQUIRE_CUDA}
ENV DOCKER_NVIDIA_REQUIRE_CUDA ""
