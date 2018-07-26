FROM nimbix/base-powerai5:5.2

# EULA from base image
RUN cp -f /etc/EULA.txt /etc/NAE/license.txt

# samples:
# this is pretty lame in that a duplicate layer is created, but the tarball
# we get is packaged by root:root and there's no way to tell Docker what user
# to untar it as, even if you use the USER directive first!
RUN mkdir -p /usr/local/samples
ADD JM.tar.gz /usr/local/samples
RUN chown -R nimbix:nimbix /usr/local/samples/*

# motd
COPY motd /etc/motd

# AppDef
COPY AppDef.json /etc/NAE/AppDef.json
RUN curl --fail -X POST -d @/etc/NAE/AppDef.json https://api.jarvice.com/jarvice/validate

# Material Compute screenshot
COPY screenshot.png /etc/NAE/screenshot.png

# TensorFlow notebook (from desktop)
RUN apt-get -y install xdg-utils && apt-get clean
COPY tensorflow-notebook.sh /usr/local/bin/tensorflow-notebook.sh
COPY tensorflow.desktop /etc/skel/Desktop/tensorflow.desktop
COPY tensorflow.png /usr/share/icons/tensorflow.png
