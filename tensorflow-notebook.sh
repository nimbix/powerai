#!/bin/bash

export PATH=/opt/anaconda3/bin:$PATH
cd
rm -rf ~/notebooks && mkdir -p ~/notebooks
cd ~/notebooks
sudo ln -s /usr/local/samples .
sudo ln -s /data .
xdg-settings set default-web-browser firefox.desktop
echo "Loading TensorFlow..."
. /opt/DL/tensorflow/bin/tensorflow-activate
echo "Starting Jupyter Notebook: press Control+C to exit, or close window..."
exec jupyter-notebook
