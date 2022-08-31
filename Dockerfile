#######################################################################
# Create an extensible SoapUI mock service runner image using Alpine
#######################################################################

# Use the alpine base image
FROM alpine

RUN apk update && \
    apk upgrade 
RUN apk add openjdk8

LABEL maintainer="fbascheper <temp01@fam-scheper.nl>"

##########################################################
# Download and unpack soapui
##########################################################

RUN addgroup -S -g 1000 soapui && adduser -S -u 1000 -G soapui --disabled-password --gecos "" -h /home/soapui soapui

RUN apk --no-cache add curl tar

RUN curl -kLO https://s3.amazonaws.com/downloads.eviware/soapuios/5.4.0/SoapUI-5.4.0-linux-bin.tar.gz && \
    echo "151ebe65215b19898e31ccbf5d5ad68b  SoapUI-5.4.0-linux-bin.tar.gz" >> MD5SUM && \
    md5sum -c MD5SUM && \
    tar -xzf SoapUI-5.4.0-linux-bin.tar.gz -C /home/soapui && \
    rm -f SoapUI-5.4.0-linux-bin.tar.gz MD5SUM

RUN chown -R soapui:soapui /home/soapui
RUN find /home/soapui -type d -exec chmod 770 {} \;
RUN find /home/soapui -type f -exec chmod 660 {} \;

##########################################################
# Install Gosu (used in docker-entrypoint.sh)
##########################################################
ENV GOSU_VERSION 1.12
RUN set -eux
RUN apk add --no-cache --virtual .gosu-deps \
        ca-certificates \
        dpkg \
        gnupg \
    ; \
    \
    dpkgArch="$(dpkg --print-architecture | awk -F- '{ print $NF }')"; \
    wget -O /usr/local/bin/gosu "https://github.com/tianon/gosu/releases/download/$GOSU_VERSION/gosu-$dpkgArch"; \
    wget -O /usr/local/bin/gosu.asc "https://github.com/tianon/gosu/releases/download/$GOSU_VERSION/gosu-$dpkgArch.asc"; \
    \
# verify the signature
    export GNUPGHOME="$(mktemp -d)"; \
    gpg --batch --keyserver hkps://keys.openpgp.org --recv-keys B42F6819007F00F88E364FD4036A9C25BF357DD4; \
    gpg --batch --verify /usr/local/bin/gosu.asc /usr/local/bin/gosu; \
    command -v gpgconf && gpgconf --kill all || :; \
    rm -rf "$GNUPGHOME" /usr/local/bin/gosu.asc; \
    \
# clean up fetch dependencies
    apk del --no-network .gosu-deps; \
    \
    chmod +x /usr/local/bin/gosu;

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
RUN find $SOAPUI_PRJ -type d -exec chmod 770 {} \;
RUN find $SOAPUI_PRJ -type f -exec chmod 660 {} \;


############################################
# Start SoapUI mock service runner
############################################

ENTRYPOINT ["/docker-entrypoint.sh"]

CMD ["start-soapui"]
