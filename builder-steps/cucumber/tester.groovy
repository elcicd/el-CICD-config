/*
 * SPDX-License-Identifier: LGPL-2.1-or-later
 *
 * Utility method for running Python pytest based unit tests
 */

def test(def projectInfo, def component) {
    sh """
        export JAVA_TOOL_OPTIONS=
        if [[ -f ${el.cicd.BUILDER_SECRETS_DIR}/maven-settings.xml ]]
        then
            mvn -D SDLC_ENV=${projectInfo.deployToEnv} -s ${el.cicd.BUILDER_SECRETS_DIR}/maven-settings.xml test
        else
            mvn -D SDLC_ENV=${projectInfo.deployToEnv} test
        fi
    """
}

return this