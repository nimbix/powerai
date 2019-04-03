#
# Copyright (c) 2019, Nimbix, Inc.
# All rights reserved.
#
# Redistribution and use in source and binary forms, with or without
# modification, are permitted provided that the following conditions are met:
#
# 1. Redistributions of source code must retain the above copyright notice,
#    this list of conditions and the following disclaimer.
# 2. Redistributions in binary form must reproduce the above copyright notice,
#    this list of conditions and the following disclaimer in the documentation
#    and/or other materials provided with the distribution.
#
# THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS "AS IS"
# AND ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE
# IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE
# ARE DISCLAIMED. IN NO EVENT SHALL THE COPYRIGHT OWNER OR CONTRIBUTORS BE
# LIABLE FOR ANY DIRECT, INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR
# CONSEQUENTIAL DAMAGES (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF
# SUBSTITUTE GOODS OR SERVICES; LOSS OF USE, DATA, OR PROFITS; OR BUSINESS
# INTERRUPTION) HOWEVER CAUSED AND ON ANY THEORY OF LIABILITY, WHETHER IN
# CONTRACT, STRICT LIABILITY, OR TORT (INCLUDING NEGLIGENCE OR OTHERWISE)
# ARISING IN ANY WAY OUT OF THE USE OF THIS SOFTWARE, EVEN IF ADVISED OF THE
# POSSIBILITY OF SUCH DAMAGE.
#
# The views and conclusions contained in the software and documentation are
# those of the authors and should not be interpreted as representing official
# policies, either expressed or implied, of Nimbix, Inc.
#

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
ADD https://raw.githubusercontent.com/IBM/powerai/powerai-1.6.0/dockerhub/LICENSE /etc/EULA-unicode.txt
RUN iconv -f unicode -t utf8 /etc/EULA-unicode.txt >/etc/EULA.txt
RUN echo "-----------------------------------------------" >>/etc/EULA.txt
RUN echo "For the Anaconda End User License Agreement, please visit:" >> /etc/EULA.txt
RUN echo "  http://docs.anaconda.com/anaconda/eula/" >> /etc/EULA.txt
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
