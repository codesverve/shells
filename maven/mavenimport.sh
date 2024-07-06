#!/bin/bash


REPO_URL="http://172.xx.xx.xx:xxx/repository/maven-snapshots"
USERNAME="mavenuser"
PASSWORD="xxxxxxx"


find . -type f -not -path './mavenimport\.sh*' -not -path './upload.sh' -not -path '*/\.*' -not -path '*/\^archetype\-catalog\.xml*' -not -path '*/\^maven\-metadata\-local*\.xml' -not -path '*/\^maven\-metadata\-deployment*\.xml' | sed "s|^\./||" | xargs -I '{}' curl -u "$USERNAME:$PASSWORD" -X PUT -v -T {} ${REPO_URL}/{} 
