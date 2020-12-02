#!/bin/bash

#
# Default usage: docker-entrypoint.sh start-soapui
#
# ==> Note: for the SoapUI command reference see http://www.soapui.org/test-automation/running-from-command-line/soap-mock.html
#

# Default value of environment variables:
#     PROJECT           = $SOAPUI_PRJ/default-soapui-project.xml
#     MOCK_SERVICE_PATH = << unset >>  ; this implies that the path in the mockservice itself is used
#
#
# The following enviroment variable is required (and has no default value)
#     MOCK_SERVICE_NAME = << unset >>
#


#
# Run entrypoint scripts of dependent docker containers
#
if [ -d /docker-entrypoint-initdb.d ]; then
    for f in /docker-entrypoint-initdb.d/*.sh; do
        [ -f "$f" ] && . "$f"
    done
fi


#
# Setup default values for environment variables.
#
if [ -z "$PROJECT" ]; then
    export PROJECT=$SOAPUI_PRJ/default-soapui-project.xml
fi

if [ -z "$MOCK_SERVICE_NAME" ]; then
    echo "Enviromentment variable MOCK_SERVICE_NAME should have been set explicitly (e.g. by  -e MOCK_SERVICE_NAME=BLZ-SOAP11-MockService"
    exit 1
fi

export PATH=$SOAPUI_DIR/bin:$PATH

cd $SOAPUI_PRJ

# create a private pipe to simulate SoapUI's "Press any key to exit"
PIPE=$(mktemp -u)
mkfifo $PIPE
exec 3<>$PIPE
rm $PIPE

function stopSoapUi {
    echo "Stopping $MOCK_SERVICE_NAME..."
    echo "Stop" >&3
}

trap stopSoapUi TERM INT

if [ "$1" = 'start-soapui' ]; then

    if [ -z "$MOCK_SERVICE_PATH" ]; then
        echo "Starting Mock-service=$MOCK_SERVICE_NAME using default mockservice url-path from SoapUI-project=$PROJECT"
        gosu soapui mockservicerunner.sh -Dsoapui.log4j.config=/home/soapui/soapui-log4j.xml -DSOAPUI_LOG_THRESHOLD=${SOAPUI_LOGLEVEL} -Djava.awt.headless=true -Dfile.encoding=UTF8 -p 8080 -m "$MOCK_SERVICE_NAME" $PROJECT <&3 &
    else
        echo "Starting Mock-service=$MOCK_SERVICE_NAME using url-path=$MOCK_SERVICE_PATH from SoapUI-project=$PROJECT"
        gosu soapui mockservicerunner.sh -Dsoapui.log4j.config=/home/soapui/soapui-log4j.xml -DSOAPUI_LOG_THRESHOLD=${SOAPUI_LOGLEVEL} -Djava.awt.headless=true -Dfile.encoding=UTF8 -p 8080 -m "$MOCK_SERVICE_NAME" -a $MOCK_SERVICE_PATH $PROJECT <&3 &
    fi

else
    echo "You can start the Mock-service manually by running"
    echo ">>>  mockservicerunner.sh -Djava.awt.headless=true -Dfile.encoding=UTF8 -p 8080 -m $MOCK_SERVICE_NAME $PROJECT"
    gosu soapui "$@" <&3 &
fi

# wait for mocksevicerunner to exit
PID=$!
wait $PID
# prevent another trap while mocksevicerunner is stopping
trap - TERM INT
# wait for stop to complete
wait $PID

