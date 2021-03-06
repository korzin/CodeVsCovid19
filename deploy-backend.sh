#!/usr/bin/env bash

set -e

SERVER_SSH=samkorzin@cmlteam.com
PORT=8099
JAVA_XMX=700
JAR_NAME="codevscovid19-0.0.1-SNAPSHOT.jar"

mydir=$(cd $(dirname "$0"); pwd)

#echo "$mydir"
echo "Build backend..."

cd "$mydir/backend"
mvn clean package -DskipTests

echo
echo "Deploy..."
echo

ssh $SERVER_SSH 'mkdir -p covid19hackathon'
scp target/$JAR_NAME $SERVER_SSH:~/covid19hackathon

echo
echo "(Re)start..."
echo

ssh $SERVER_SSH '
set -e
echo "pkill...";

PORT=$(sudo lsof -t -i:8099);

if [[ $PORT ]]
then
sudo kill -9 $PORT;
fi;

echo "staring..."
nohup java \
    -Xmx'${JAVA_XMX}'M \
    -Xms'${JAVA_XMX}'M \
    -jar covid19hackathon/'$JAR_NAME' &> ~/codeVsCivid19.log &
tail -f ~/codeVsCivid19.log
'
