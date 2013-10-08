#!/bin/bash
mongo --host $OPENSHIFT_NOSQL_DB_HOST --port $OPENSHIFT_NOSQL_DB_PORT -u $OPENSHIFT_NOSQL_DB_USERNAME -p$OPENSHIFT_NOSQL_DB_PASSWORD coderstats counts_user_repos.js
