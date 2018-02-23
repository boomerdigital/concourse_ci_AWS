#!/bin/bash

set -e

exec /usr/local/bin/concourse worker \
 --work-dir /opt/concourse/worker \
 --peer-ip 10.1.1.20 \
 --bind-ip 10.1.1.20 \
 --tsa-host 10.1.1.10 \
 --baggageclaim-bind-ip 10.1.1.20 \
 --tsa-public-key /var/lib/concourse/keys/web/tsa_host_key.pub \
 --tsa-worker-private-key /var/lib/concourse/keys/worker/worker_key
