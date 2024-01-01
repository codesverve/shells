#!/bin/bash

# Variables
SPLUNK_HOME="/opt/splunk"
SPLUNK_USER="splunk"
SPLUNK_GROUP="splunk"
SPLUNK_PACKAGE="～/splunk-9.1.2-b6b9c8185839-Linux-x86_64.tgz"

# Create Splunk user and group
groupadd $SPLUNK_GROUP
useradd -r -m -g $SPLUNK_GROUP $SPLUNK_USER

# Extract Splunk package
tar -xzf $SPLUNK_PACKAGE -C /opt

# Change ownership of Splunk directory
chown -R $SPLUNK_USER:$SPLUNK_GROUP $SPLUNK_HOME

# Enable boot-start for Splunk
$SPLUNK_HOME/bin/splunk enable boot-start -user $SPLUNK_USER

# Start Splunk
#$SPLUNK_HOME/bin/splunk start --accept-license
