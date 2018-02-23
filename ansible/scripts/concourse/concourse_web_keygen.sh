#!/bin/sh

su ec2-user -e


ssh-keygen -t rsa -N "" -f /var/lib/concourse/keys/web/tsa_host_key
ssh-keygen -t rsa -N "" -f /var/lib/concourse/keys/worker/worker_key
ssh-keygen -t rsa -N "" -f /var/lib/concourse/keys/web/session_signing_key

cp /var/lib/concourse/keys/worker/worker_key.pub /var/lib/concourse/keys/worker/authorized_worker_keys
