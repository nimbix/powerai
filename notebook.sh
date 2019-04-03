#!/bin/bash

sudo service ssh start

. /etc/profile.d/conda.sh

conda activate
redir --laddr=0.0.0.0 --lport=443 --caddr=127.0.0.1 --cport=8888 &

cd /usr/local/notebook
sudo chown -R `id -u`:`id -g` /usr/local/notebook/samples &
export SHELL=/bin/bash
exec jupyter notebook --ip=127.0.0.1 --no-browser --port=8888 \
    --certfile=/etc/JARVICE/cert.pem \
    --NotebookApp.allow_remote_access=True \
    --NotebookApp.token=`cat /etc/JARVICE/random128.txt | cut -c 1-64`
