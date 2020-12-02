# SoapUI Mock-Service Docker image

This project builds a docker container for running a Mock-Service with SOAP-UI

        $ docker build -t fbascheper/soapui-mockservice-runner .

## Running the image

You can run the mock-service container interactively with the following command:

        $ docker run -P -it --rm -e MOCK_SERVICE_NAME=BLZ-SOAP11-MockService  <<image-id>>

        $ docker run -P -it --rm \
            -e MOCK_SERVICE_NAME=BLZ-SOAP11-MockService \
            -e MOCK_SERVICE_PATH=/BLZMockService \
            -e PROJECT=/home/soapui/soapui-prj/default-soapui-project.xml \
             <<image-id>>
                 

And of course you can also run it as a daemon, e.g. using:
 
        $ docker run --name soapui-daemon -d -e MOCK_SERVICE_NAME=BLZ-SOAP11-MockService  <<image-id>>


## Mounting a local directory
Thanks to [Jun SAITO](https://github.com/st63jun) it is also possible to mount a host directory and deploy a mock service in a locally stored 
SoapUI project XML file. The example below demonstrates this by downloading the SoapUI project in the docker image
in a newly created ``soapui-test-project`` directory of the ``$HOME`` directory.

        $ mkdir -p $HOME/soapui-test-project
        $ cd $HOME/soapui-test-project 
        $ wget https://raw.githubusercontent.com/fbascheper/SoapUI-MockService-Docker-image/master/soapui-prj/default-soapui-project.xml

        $ docker run -P -it --rm \
            -p 8080:8080 \
            -v "$HOME/soapui-test-project:/home/soapui/soapui-prj/" \
            -e MOCK_SERVICE_NAME="BLZ-SOAP11-MockService" \
            -e PROJECT=/home/soapui/soapui-prj/default-soapui-project.xml \
            -e SOAPUI_LOGLEVEL=INFO \
            --privileged \
             <<image-id>>


If all goes well, you should now be able to access the WSDL at the location ``http://localhost:8080/BLZ-SOAP11-MockService?WSDL``


## Supported environment variables

The following environment variables are supported:

<table>
    <tr>
        <th>Name</th>
        <th>Required</th>
        <th>Default value</th>
        <th>Description</th>
    </tr>    
    <tr>
        <td><code>MOCK_SERVICE_NAME</code></td>
        <td>YES</td>
        <td>Empty</td>
        <td>Name of the mock service in the SoapUI project file</td>
    </tr>
    <tr>
        <td><code>MOCK_SERVICE_PATH</code></td>
        <td>NO</td>
        <td>Empty</td>
        <td>Path used to publish the mock service, if empty the path in the SoapUI project file is used</td>
    </tr>
    <tr>
        <td><code>PROJECT</code></td>
        <td>NO</td>
        <td>/home/soapui/soapui-prj/default-soapui-project.xml</td>
        <td>The complete path to the SoapUI project file</td>
    </tr>
    <tr>
        <td><code>SOAPUI_LOGLEVEL</code></td>
        <td>NO</td>
        <td>WARN</td>
        <td>Changes then default logging level, possible values ERROR, WARN, INFO, DEBUG</td>
    </tr>
</table>


## Creating mock services based on this image

The extension-mechanism works in the same fashion as the postgresql docker image, i.e. by adding your own shell script in 
the docker-entrypoint-initdb directory. But as a rule this should not be necessary. 

The best practice for creating a new image is to add your own SoapUI project in the soapui-prj directory and reference this project 
using the supported environment variables.
 

