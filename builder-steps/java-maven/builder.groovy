/* 
 * SPDX-License-Identifier: LGPL-2.1-or-later
 *
 * Utility method for building Java Maven microservices
 *
 */

def build(def projectInfo, def microService) {
    sh """
        export JAVA_TOOL_OPTIONS=
        if [[ -f ${el.cicd.BUILD_SECRETS_DIR}/settings.xml ]]
        then
            mvn -s ${el.cicd.BUILD_SECRETS_DIR}/settings.xml -DskipTests --batch-mode clean package
        else
            mvn -DskipTests --batch-mode clean package
        fi
    """
}

return this