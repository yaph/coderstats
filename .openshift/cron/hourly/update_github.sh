#!/bin/bash
cd ../../../
ruby update.rb >> $OPENSHIFT_LOG_DIR/update_github.log
