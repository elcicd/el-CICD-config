/* 
 * SPDX-License-Identifier: LGPL-2.1-or-later
 *
 * Utility method for scanning R language based components
 */

def analyze(def projecInfo, def module) {
    /*withCredentials([string(credentialsId: el.cicd.SONARQUBE_ACCESS_TOKEN_ID, variable: 'SONARQUBE_ACCESS_TOKEN')]) {
        // sonar.sources=. -> define source code directory
        // sonar.tests=./tests ->  define directory for test code; ./tests must exist or the build will fail
        // sonar.login=${SONARQUBE_ACCESS_TOKEN} -> use access token generated by sonarqube (associated with client service account)
        // project.settings=/usr/local/sonar-scanner/conf/sonar-scanner.properties -> default scanner settings in jenkins slave image
        // sonar.exclusions=tests/**,venv/**,*.xml -> excluse test code directories from being included in base code scan
        // *.reportPath=... location of generated reports to collect and send to SonarQube
        sh """
            unset JAVA_TOOL_OPTIONS
            export SONAR_SCANNER_OPTS="-Xmx512m"
            sonar-scanner -Dsonar.sources=. \
                          -Dsonar.projectName=${component.name} \
                          -Dsonar.projectKey=${projectInfo.id}-${component.name} \
                          -Dsonar.host.url=http://sonarqube.jenkins-pipeline.svc.cluster.local:9000 \
                          -Dsonar.login=${SONARQUBE_ACCESS_TOKEN} \
                          -Dproject.settings=/usr/local/sonar-scanner/conf/sonar-scanner.properties \
                          -Dsonar.dependencyCheck.reportPath=./dependency-check-report.xml \
                          -Dsonar.dependencyCheck.htmlReportPath=./dependency-check-report.html \
                          -Dsonar.sonar.testExecutionReportPaths=./test_result.xml \
                          -Dsonar.coverageReportPaths=./coverage.xml \
                          -Dsonar.exclusions=tests/**,renv/**,*.xml
        """
    }*/
    echo "--> FAKE R-LANG CODE ANALYSIS"
}

return this

