/* 
 * SPDX-License-Identifier: LGPL-2.1-or-later
 *
 * Example script where system tests can be run...
 */

def runTests(def projectInfo, def microServicesToTest, def systemTestNamespace, def systemTestEnv) {
    def msgs = ["[CUCUMBER RUNNER EXAMPLE PLACEHOLDER]",
                "Testing in ${systemTestNamespace} for the ${systemTestEnv.toUpper} environment:"]
    msgs.addAll(microServicesToTest.collect { it.name })

    pipelineUtils.echoBanner(msgs)
}

return this