
# SoapUI Mock-Service Docker image
This project builds a docker container for running a Mock-Service with SOAP-UI


## Building the image

Before running the build:

1. Install [Docker](https://www.docker.io/gettingstarted/#1)
2. Setup the /distribution directory, by adding the JBoss EAP 6.4.0 zip distribution and any roll-up patch files (jboss-eap-6.4.0.zip / jboss-eap-6.4.x-patch.zip)
3. Setup the /jce-unlimited directory, by adding the JCE unlimited policy files (local_policy.jar / US_export_policy.jar)
4. Setup the /trusted-root-ca directory, by adding your trusted root CA files (in .pem format)

Once you have completed steps 1..4 you can build an image using the following command:

		$ docker build .


You can run the mock-service container interactively with the following command:

        $ docker run -P -it --rm -e MOCK_SERVICE_NAME=BLZ-SOAP11-MockService  <<image-id>>

        $ docker run -P -it --rm \
            -e MOCK_SERVICE_NAME=BLZ-SOAP11-MockService \
            -e MOCK_SERVICE_PATH=/BLZMockService \
            -e PROJECT=/home/soapui/soapui-prj/default-soapui-project.xml \
             <<image-id>>
                 

And of course you can also run it as a daemon, e.g. using:
 
        $ docker run --name soapui-daemon -d -e MOCK_SERVICE_NAME=BLZ-SOAP11-MockService  <<image-id>>


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
</table>


## Creating mock services based on this image

The extension-mechanism works in the same fashion as the postgresql docker image, i.e. by adding your own shell script in 
the docker-entrypoint-initdb directory. But as a rule this should not be necessary. 

The best practice for creating a new image is to add your own SoapUI project in the soapui-prj directory and reference this project 
using the supported environment variables.
 

