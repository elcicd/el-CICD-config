/* 
 * SPDX-License-Identifier: LGPL-2.1-or-later
 *
 * Utility method for running unit tests in Java Maven microservices
 */

def test(def projectInfo, def microService) {
    sh """
        export JAVA_TOOL_OPTIONS=
        if [[ -f ${el.cicd.BUILDER_SECRETS_DIR}/settings.xml ]]
        then
            mvn -s ${el.cicd.BUILDER_SECRETS_DIR}/settings.xml test
        else
            mvn test
        fi
    """
}

return this