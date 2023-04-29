/* 
 * SPDX-License-Identifier: LGPL-2.1-or-later
 *
 * Utility method for running post processing of component code before the image build
 */

def assemble(def projectInfo, def component) {
    // clean r-lang workspace after scanner step complete
    sh "git clean -fxd"
}

return this