#!/bin/bash
ruby ${OPENSHIFT_APP_DIR}repo/update.rb >> $OPENSHIFT_LOG_DIR/update_github.log
