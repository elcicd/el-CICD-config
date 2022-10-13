/* 
 * SPDX-License-Identifier: LGPL-2.1-or-later
 *
 * Example script where system tests can be run...
 */

def runTests(def projectInfo, def componentToTest, def testModuleNamespace, def testModuleEnv) {
    def msgs = ["[SPOCK RUNNER EXAMPLE PLACEHOLDER]",
                "Testing ${componentToTest.name} in ${testModuleNamespace} for the ${testModuleEnv.toUpperCase()} environment"]

    loggingUtils.echoBanner(msgs)
}

return this