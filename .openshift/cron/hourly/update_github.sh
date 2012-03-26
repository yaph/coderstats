#!/bin/bash
ruby ${OPENSHIFT_REPO_DIR}repo/update.rb >> $OPENSHIFT_LOG_DIR/update_github.log
