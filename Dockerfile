#######################################################################
# Create an extensible SoapUI mock service runner image using CentOS
#######################################################################

# Use the centos 6.7 base image
FROM centos:6.7

MAINTAINER fbascheper <temp01@fam-scheper.nl>

# Update the system
RUN yum -y update;yum clean all

##########################################################
# Install Java JDK
##########################################################
RUN yum -y install wget && \
    wget --no-check-certificate --no-cookies --header "Cookie: oraclelicense=accept-securebackup-cookie" http://download.oracle.com/otn-pub/java/jdk/8u65-b17/jdk-8u65-linux-x64.rpm && \
    echo "1e587aca2514a612b10935813b1cef28  jdk-8u65-linux-x64.rpm" >> MD5SUM && \
    md5sum -c MD5SUM && \
    rpm -Uvh jdk-8u65-linux-x64.rpm && \
    yum -y remove wget && \
    rm -f jdk-8u65-linux-x64.rpm MD5SUM

ENV JAVA_HOME /usr/java/jdk1.8.0_65


##########################################################
# Download and unpack soapui
##########################################################

RUN groupadd -r soapui && useradd -r -g soapui -m -d /home/soapui soapui

RUN yum -y install wget && yum -y install tar && \
    wget --no-check-certificate --no-cookies http://cdn01.downloads.smartbear.com/soapui/5.2.1/SoapUI-5.2.1-linux-bin.tar.gz && \
    echo "ba51c369cee1014319146474334fb4e1  SoapUI-5.2.1-linux-bin.tar.gz" >> MD5SUM && \
    md5sum -c MD5SUM && \
    tar -xzf SoapUI-5.2.1-linux-bin.tar.gz -C /home/soapui && \
    yum -y remove wget && yum -y remove tar && \
    rm -f SoapUI-5.2.1-linux-bin.tar.gz MD5SUM

RUN chown -R soapui:soapui /home/soapui
RUN find /home/soapui -type d -execdir chmod 770 {} \;
RUN find /home/soapui -type f -execdir chmod 660 {} \;

RUN yum -y install curl && \
    curl -o /usr/local/bin/gosu -SL "https://github.com/tianon/gosu/releases/download/1.3/gosu-amd64" && \
    chmod +x /usr/local/bin/gosu

############################################
# Setup MockService runner
############################################

USER soapui
ENV HOME /home/soapui
ENV SOAPUI_DIR /home/soapui/SoapUI-5.2.1
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
