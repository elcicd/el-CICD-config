/* 
 * SPDX-License-Identifier: LGPL-2.1-or-later
 *
 * Utility method for running post processing of microservice code before the image build
 */

def package(def projectInfo, def microService) {
    // clean r-lang workspace after scanner step complete
    sh "git clean -fxd"
}

return this