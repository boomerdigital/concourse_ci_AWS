#!/bin/bash

set -e

exec /usr/local/bin/concourse web \
 --basic-auth-username <your_concourse_un> \
 --basic-auth-password <your_concourse_pw> \
 --bind-ip 10.1.1.10 \
 --bind-port 8080 \
 --tsa-bind-ip 10.1.1.10 \
 --tsa-bind-port 2222 \
 --tsa-peer-ip 10.1.1.10 \
 --peer-url http://10.1.1.10:8080 \
 --session-signing-key /var/lib/concourse/keys/web/session_signing_key \
 --tsa-host-key /var/lib/concourse/keys/web/tsa_host_key \
 --tsa-authorized-keys /var/lib/concourse/keys/worker/authorized_worker_keys \
 --postgres-data-source postgres://<your_db_user>:<your_db_user_pw>@"<DB instance endpoint>":5432/<your_db_name>?sslmode=disable \
 --external-url http://<your_ci_server_domain>
