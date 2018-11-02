#######################################################################
# Create an extensible SoapUI mock service runner image using CentOS
#######################################################################

# Use the openjdk 8 base image
FROM openjdk:8

MAINTAINER fbascheper <temp01@fam-scheper.nl>

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

RUN apt-get update \
    && apt-get install -y --no-install-recommends \
        cron \
        gosu \
    && rm -rf /var/lib/apt/lists/*

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
