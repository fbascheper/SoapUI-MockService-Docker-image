# SoapUI Mock-Service Docker image

Este projeto constroi um container docker para executar um Mock-Service com o SOAP-UI

        $ docker build -t fbascheper/soapui-mockservice-runner .

## Executando a imagem

Voê pode executar o mock-service container interativamente com o seguinte comando:

        $ docker run -P -it --rm -e MOCK_SERVICE_NAME=BLZ-SOAP11-MockService  <<image-id>>

        $ docker run -p 8080:8080 -it --rm \
            -e MOCK_SERVICE_NAME=BLZ-SOAP11-MockService \
            -e MOCK_SERVICE_PATH=/BLZMockService \
            -e PROJECT=/home/soapui/soapui-prj/default-soapui-project.xml \
             <<image-id>>

** Preencha as variáveis de ambiente (MOCK_SERVICE_NAME, MOCK_SERVICE_PATH) com os mesmos dados informados no projeto que será importado. 


E é claro, você pode executá-lo apenas como um daemon, usando:
 
        $ docker run --name soapui-daemon -d -e MOCK_SERVICE_NAME=BLZ-SOAP11-MockService  <<image-id>>


## Montando um diretório local
Agradecimentos para [Jun SAITO](https://github.com/st63jun) que possibilitou montar um diretório local e executar um mock service a partir de um arquivo
SoapUI project XML armazenado localmente. O exemplo a seguir demonstra isso. O SoapUI project é baixado para um diretório recém criado. Este diretório é montado durante a invoação do container e o SoapUI project é executado pelo container

        $ mkdir -p $HOME/soapui-test-project
        $ cd $HOME/soapui-test-project 
        $ wget https://raw.githubusercontent.com/fbascheper/SoapUI-MockService-Docker-image/master/soapui-prj/default-soapui-project.xml

        $ docker run -P -it --rm \
            -p 8080:8080 \
            -v "$HOME/soapui-test-project:/home/soapui/soapui-prj/" \
            -e MOCK_SERVICE_NAME="BLZ-SOAP11-MockService" \
            -e PROJECT=/home/soapui/soapui-prj/default-soapui-project.xml \
            --privileged \
             <<image-id>>


Se tudo deu certo, você agora deve estar apto a acessar o WSDL no endereço ``http://localhost:8080/BLZ-SOAP11-MockService?WSDL``


## Variáveis de ambiente suportadas

As seguintes variáveis de ambiente são suportadas:

<table>
    <tr>
        <th>Nome</th>
        <th>Obrigatória</th>
        <th>Valor default</th>
        <th>Descrição</th>
    </tr>    
    <tr>
        <td><code>MOCK_SERVICE_NAME</code></td>
        <td>SIM</td>
        <td>Vazio</td>
        <td>Nome do mock service no SoapUI project</td>
    </tr>
    <tr>
        <td><code>MOCK_SERVICE_PATH</code></td>
        <td>NÃO</td>
        <td>Vazio</td>
        <td>Caminho usado para publicar o mock service, se não for informado, o caminho contido no SoapUI project será usado</td>
    </tr>
    <tr>
        <td><code>PROJECT</code></td>
        <td>NÃO</td>
        <td>/home/soapui/soapui-prj/default-soapui-project.xml</td>
        <td>O caminho completo para o arquivo SoapUI project</td>
    </tr>
</table>


## Criando um mock services baseado nesta imagem

O extension-mechanism funciona da mesma forma que a imagem do docker postgresql, através da adição dos seus próprios shell scripts no diretório docker-entrypoint-initdb. Mas como uma regra, isto não deve ser necessário. 

A melhor forma para criar uma imagem é adicionar o seu próprio SoapUI project no diretório soapui-prj e referenciar este projeto usando as variáveis de ambiente suportadas.
 

