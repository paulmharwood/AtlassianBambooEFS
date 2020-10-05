FROM adoptopenjdk:8-jdk-hotspot-bionic
LABEL maintainer="Fujitsu Swansea" \
      description="Variation of Official Bamboo Server Docker Image for Fargate and EFS in AWS"

ENV RUN_USER                                        bamboo
ENV RUN_GROUP                                       bamboo
ENV RUN_UID                                         2001
ENV RUN_GID                                         2001

# https://confluence.atlassian.com/display/JSERVERM/Important+directories+and+files
ENV BAMBOO_HOME                                       /var/atlassian/application-data/bamboo
ENV BAMBOO_INSTALL_DIR                                /opt/atlassian/bamboo

WORKDIR $BAMBOO_HOME

EXPOSE 54663
EXPOSE 8085


ENTRYPOINT ["/tini", "--"]
CMD ["/entrypoint.sh"]

RUN set -x && \
      apt-get update && \
      apt-get install -y --no-install-recommends \
            curl \
            git \
            bash \
            procps \
            openssl \
            openssh-client \
            libtcnative-1 \
            maven \
            && \
            # create symlink to maven to automate capability detection
            ln -s /usr/share/maven /usr/share/maven3 && \
            # create symlink for java home backward compatibility
            mkdir -m 755 -p /usr/lib/jvm && \
            ln -s "${JAVA_HOME}" /usr/lib/jvm/java-8-openjdk-amd64 && \
            rm -rf /var/lib/apt/lists/*

ARG TINI_VERSION=v0.18.0
ADD https://github.com/krallin/tini/releases/download/${TINI_VERSION}/tini /tini
RUN chmod +x /tini

ARG BAMBOO_VERSION
ARG DOWNLOAD_URL=https://www.atlassian.com/software/bamboo/downloads/binary/atlassian-bamboo-${BAMBOO_VERSION}.tar.gz

RUN groupadd --gid ${RUN_GID} ${RUN_GROUP} \
      && useradd --uid ${RUN_UID} --gid ${RUN_GID} --home-dir ${BAMBOO_HOME} --shell /bin/bash ${RUN_USER} 


RUN set -x && \
      mkdir -p ${BAMBOO_INSTALL_DIR}/lib/native && \
      mkdir -p ${BAMBOO_HOME} 

RUN mkdir -p ${BAMBOO_INSTALL_DIR}/lib/native
RUN ln --symbolic "/usr/lib/x86_64-linux-gnu/libtcnative-1.so" "${BAMBOO_INSTALL_DIR}/lib/native/libtcnative-1.so"
RUN curl --silent -L ${DOWNLOAD_URL} | tar -xz --strip-components=1 -C "$BAMBOO_INSTALL_DIR" 
RUN echo "bamboo.home=${BAMBOO_HOME}" > $BAMBOO_INSTALL_DIR/atlassian-bamboo/WEB-INF/classes/bamboo-init.properties
RUN chown -R "${RUN_USER}:${RUN_GROUP}" "${BAMBOO_INSTALL_DIR}"
RUN chown -R "${RUN_USER}:${RUN_GROUP}" "${BAMBOO_HOME}"    

VOLUME ["${BAMBOO_HOME}"]

COPY  entrypoint.sh /entrypoint.sh
