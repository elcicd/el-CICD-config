/* 
 * SPDX-License-Identifier: LGPL-2.1-or-later
 *
 * Example script where system tests can be run...
 */

def runTests(def projectInfo, def componentToTest, def testComponentNamespace, def testComponentEnv) {
    def msgs = ["[CUCUMBER RUNNER EXAMPLE PLACEHOLDER]",
                "Testing ${componentToTest.name} in ${testComponentNamespace} for the ${testComponentEnv.toUpperCase()} environment"]

    loggingUtils.echoBanner(msgs)
}

return this