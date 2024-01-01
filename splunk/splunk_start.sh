#!/bin/bash

# Variables
SPLUNK_HOME="/opt/splunk"
SPLUNK_USER="splunk"
SPLUNK_GROUP="splunk"
SPLUNK_PACKAGE="~/splunk-9.1.2-b6b9c8185839-Linux-x86_64.tgz"


# Start Splunk
$SPLUNK_HOME/bin/splunk start --accept-license
