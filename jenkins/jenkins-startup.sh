#!/bin/bash
echo "Jenkins plugins to install:"

cat ${1}

echo
java -jar /usr/share/java/jenkins-plugin-manager.jar \
      --war /usr/share/java/jenkins.war \
      -f ${1} \
      --plugin-download-directory ${JENKINS_HOME}/plugins
      
java -Djenkins.install.runSetupWizard=false \
     -Dhudson.security.csrf.GlobalCrumbIssuerConfiguration.DISABLE_CSRF_PROTECTION=true \
     ${JENKINS_JAVA_OVERRIDES} \
     -jar /usr/share/java/jenkins.war