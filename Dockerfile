#######################################################################
# Create an extensible SoapUI mock service runner image using CentOS
#######################################################################

# Use the centos 7 base image
FROM centos:7

MAINTAINER fbascheper <temp01@fam-scheper.nl>

# Update the system
RUN yum -y update;yum clean all

##########################################################
# Install Java JDK
##########################################################
RUN yum -y install wget && \
    wget --no-check-certificate --no-cookies --header "Cookie: oraclelicense=accept-securebackup-cookie" http://download.oracle.com/otn-pub/java/jdk/8u181-b13/96a7b8442fe848ef90c96a2fad6ed6d1/jdk-8u181-linux-x64.rpm && \
    echo "e7c0593a310b83b4ca69ea22f850c71f jdk-8u181-linux-x64.rpm" >> MD5SUM && \
    md5sum -c MD5SUM && \
    rpm -Uvh jdk-8u181-linux-x64.rpm && \
    yum -y remove wget && \
    rm -f jdk-8u181-linux-x64.rpm MD5SUM

ENV JAVA_HOME /usr/java/jdk1.8.0_181


##########################################################
# Download and unpack soapui
##########################################################

RUN groupadd -r -g 1000 soapui && useradd -r -u 1000 -g soapui -m -d /home/soapui soapui

RUN curl -kLO https://s3.amazonaws.com/downloads.eviware/soapuios/5.4.0/SoapUI-5.4.0-linux-bin.tar.gz && \
    echo "151ebe65215b19898e31ccbf5d5ad68b SoapUI-5.4.0-linux-bin.tar.gz" >> MD5SUM && \
    md5sum -c MD5SUM && \
    tar -xzf SoapUI-5.4.0-linux-bin.tar.gz -C /home/soapui && \
    rm -f SoapUI-5.4.0-linux-bin.tar.gz MD5SUM

RUN chown -R soapui:soapui /home/soapui
RUN find /home/soapui -type d -execdir chmod 770 {} \;
RUN find /home/soapui -type f -execdir chmod 660 {} \;

RUN yum -y install curl && \
    curl -o /usr/local/bin/gosu -SL "https://github.com/tianon/gosu/releases/download/1.10/gosu-amd64" && \
    chmod +x /usr/local/bin/gosu

############################################
# Setup MockService runner
############################################

USER soapui
ENV HOME /home/soapui
ENV SOAPUI_DIR /home/soapui/SoapUI-5.4.0
ENV SOAPUI_PRJ /home/soapui/soapui-prj

############################################
# Add customization sub-directories (for entrypoint)
############################################
ADD docker-entrypoint-initdb.d  /docker-entrypoint-initdb.d
ADD soapui-prj                  $SOAPUI_PRJ

############################################
# Expose ports and start SoapUI mock service
############################################
USER root

EXPOSE 8080

COPY docker-entrypoint.sh /
RUN chmod 700 /docker-entrypoint.sh
RUN chmod 770 $SOAPUI_DIR/bin/*.sh

RUN chown -R soapui:soapui $SOAPUI_PRJ
RUN find $SOAPUI_PRJ -type d -execdir chmod 770 {} \;
RUN find $SOAPUI_PRJ -type f -execdir chmod 660 {} \;


############################################
# Start SoapUI mock service runner
############################################

ENTRYPOINT ["/docker-entrypoint.sh"]

CMD ["start-soapui"]
