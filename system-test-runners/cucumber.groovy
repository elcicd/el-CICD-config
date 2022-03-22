/* 
 * SPDX-License-Identifier: LGPL-2.1-or-later
 *
 * Example script where system tests can be run...
 */

def runTests(def projectInfo, def microServicesToTest, def systemTestNamespace, def systemTestEnv) {
    def msgs = ["[CUCUMBER RUNNER EXAMPLE PLACEHOLDER]",
                "Testing ${microServicesToTest} in ${systemTestNamespace} for the ${systemTestEnv.toUpperCase()} environment:"]

    pipelineUtils.echoBanner(msgs)
}

return this