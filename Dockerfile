FROM nimbix/base-powerai5:5.0

# EULA from base image
RUN cp -f /etc/EULA.txt /etc/NAE/license.txt

# motd
COPY motd /etc/motd

# AppDef
COPY AppDef.json /etc/NAE/AppDef.json
RUN curl --fail -X POST -d @/etc/NAE/AppDef.json https://api.jarvice.com/jarvice/validate

# Material Compute screenshot
COPY screenshot.png /etc/NAE/screenshot.png

