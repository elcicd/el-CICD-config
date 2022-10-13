#!/bin/bash

if [[ -f ${JENKINS_PLUGINS_FILE} ]]
then 
    echo "Installing Jenkins Plugins:"
    cat ${JENKINS_PLUGINS_FILE}

    echo
    java -jar /usr/share/java/jenkins-plugin-manager.jar \
        --war /usr/share/java/jenkins.war \
        -f ${JENKINS_PLUGINS_FILE} \
        --plugin-download-directory ${JENKINS_HOME}/plugins
fi

if [[ -d ${CONFIG_MAP_JOBS_DIR} ]]
then
    mkdir -p ${JENKINS_HOME}/jobs
    chmod 777 -Rv ${JENKINS_HOME}/jobs
    rm -rfv ${JENKINS_HOME}/jobs/*
    $(cd ${JENKINS_HOME}/mounted-jenkins-jobs/; find -L . -not -path '*/.*' -name config.xml -exec cp --parents '{}' ../jobs \;)
    chmod 777 -Rv ${JENKINS_HOME}/jobs
fi
      
java -Djenkins.install.runSetupWizard=false \
     -Dhudson.security.csrf.GlobalCrumbIssuerConfiguration.DISABLE_CSRF_PROTECTION=true \
     ${JENKINS_JAVA_OVERRIDES} \
     -jar /usr/share/java/jenkins.war