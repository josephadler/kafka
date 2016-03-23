# Licensed to the Apache Software Foundation (ASF) under one or more
# contributor license agreements.  See the NOTICE file distributed with
# this work for additional information regarding copyright ownership.
# The ASF licenses this file to You under the Apache License, Version 2.0
# (the "License"); you may not use this file except in compliance with
# the License.  You may obtain a copy of the License at
#
#    http://www.apache.org/licenses/LICENSE-2.0
#
# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS,
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
# See the License for the specific language governing permissions and
# limitations under the License.

#!/bin/bash

# Usage: connect-worker.sh <group ID> <list broker public hostname or IP + port>

set -e

GROUP_ID=$1
BROKER_ADDRESSES=$2

sudo apt-get -y install git maven
mvn install:install-file -Dfile=/opt/kakfa-trunk/core/build/libs/kafka_2.11-0.10.0.0-SNAPSHOT.jar \
 -DgroupId=org.apache.kafka -DartifactId=kafka_2.11 -Dversion=0.10.0.0-SNAPSHOT -Dpackaging=jar
mvn install:install-file -Dfile=/opt/kakfa-trunk/clients/build/libs/kafka-clients-0.10.0.0-SNAPSHOT.jar \
 -DgroupId=org.apache.kafka -DartifactId=kafka-clients -Dversion=0.10.0.0-SNAPSHOT -Dpackaging=jar
mvn install:install-file -Dfile=/opt/kakfa-trunk/clients/build/libs/kafka-connect-0.10.0.0-SNAPSHOT.jar \
 -DgroupId=org.apache.kafka -DartifactId=kafka-connect -Dversion=0.10.0.0-SNAPSHOT -Dpackaging=jar
git clone https://github.com/confluentinc/common.git
git clone https://github.com/confluentinc/rest-utils.git
git clone https://github.com/confluentinc/schema-registry.git

kafka_dir=/opt/kafka-trunk
cd $kafka_dir

sed \
    -e 's/group.id=connect-cluster/'group.id=$GROUP_ID'/' \
    -e 's/bootstrap.servers=localhost:2181/'bootstrap.servers=$BROKER_ADDRESSES'/' \
    $kafka_dir/config/connect-distributed.properties > $kafka_dir/config/connect-worker-$GROUP_ID.properties

#echo "Killing server"
#bin/kafka-server-stop.sh || true
#sleep 5 # Because kafka-server-stop.sh doesn't actually wait
#echo "Starting server"
#if [[  -n $JMX_PORT ]]; then
#  export JMX_PORT=$JMX_PORT
#  export KAFKA_JMX_OPTS="-Djava.rmi.server.hostname=$PUBLIC_ADDRESS -Dcom.sun.management.jmxremote -Dcom.sun.management.jmxremote.authenticate=false  -Dcom.sun.management.jmxremote.ssl=false "
#fi
#bin/kafka-server-start.sh $kafka_dir/config/server-$BROKER_ID.properties 1>> /tmp/broker.log 2>> /tmp/broker.log &
bin/connect-distributed $kafka_dir/config/connect-worker-$GROUP_ID.properties 1>> /tmp/worker.log 2>> /tmp/worker.log &