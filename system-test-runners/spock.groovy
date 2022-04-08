/* 
 * SPDX-License-Identifier: LGPL-2.1-or-later
 *
 * Example script where system tests can be run...
 */

def runTests(def projectInfo, def microServiceToTest, def systemTestNamespace, def systemTestEnv) {
    def msgs = ["[SPOCK RUNNER EXAMPLE PLACEHOLDER]",
                "Testing ${microServiceToTest.name} in ${systemTestNamespace} for the ${systemTestEnv.toUpperCase()} environment"]

    pipelineUtils.echoBanner(msgs)
}

return this