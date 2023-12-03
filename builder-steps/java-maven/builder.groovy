/* 
 * SPDX-License-Identifier: LGPL-2.1-or-later
 *
 * Utility method for building Java Maven components
 *
 */

def build(def projectInfo, def component) {
    sh """
        export JAVA_TOOL_OPTIONS=
        if [[ -f ${el.cicd.BUILDER_SECRETS_DIR}/maven-settings.xml ]]
        then
            mvn -s ${el.cicd.BUILDER_SECRETS_DIR}/maven-settings.xml -DskipTests --batch-mode clean package
        else
            mvn -DskipTests --batch-mode clean package
        fi
    """
}

return this