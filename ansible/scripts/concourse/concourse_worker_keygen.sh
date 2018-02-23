#!/bin/sh

su ec2-user -e

ssh-keygen -t rsa -N "" -f /var/lib/concourse/keys/worker/worker_key

