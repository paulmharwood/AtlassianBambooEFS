#!/bin/bash
set -euo pipefail

: ${JAVA_OPTS:=}
: ${CATALINA_OPTS:=}

# Bamboo should not run Repository-stored Specs in Docker while being run in a Docker container itself.
# Only affects the installation phase. Has no effect once Bamboo is set up.
CATALINA_OPTS="${CATALINA_OPTS} -Dbamboo.setup.rss.in.docker=false"

export JAVA_OPTS="${JAVA_OPTS}"
export CATALINA_OPTS="${CATALINA_OPTS}"

export LC_ALL=C.UTF-8
export LANG=C.UTF-8
export LANGUAGE=C.UTF-8

# Start Bamboo as the correct user.
if [ "${UID}" -eq 0 ]; then
    echo "User is currently root. Will change directory ownership to ${RUN_USER}:${RUN_GROUP}, then downgrade permission to ${RUN_USER}"
    PERMISSIONS_SIGNATURE=$(stat -c "%u:%U:%a" "${BAMBOO_HOME}")
    EXPECTED_PERMISSIONS=$(id -u ${RUN_USER}):${RUN_GROUP}:700
    if [ "${PERMISSIONS_SIGNATURE}" != "${EXPECTED_PERMISSIONS}" ]; then
        echo "Updating permissions for BAMBOO_HOME"
        mkdir -p "${BAMBOO_HOME}/lib" &&
            chmod -R 700 "${BAMBOO_HOME}" &&
            chown -R "${RUN_USER}:${RUN_GROUP}" "${BAMBOO_HOME}"
    fi

    # Now drop privileges.
    exec su -s /bin/bash "${RUN_USER}" -c "${BAMBOO_INSTALL_DIR}/bin/start-bamboo.sh -fg"
else
    exec "${BAMBOO_INSTALL_DIR}/bin/start-bamboo.sh" "-fg"
fi

