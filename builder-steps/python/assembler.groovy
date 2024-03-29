/* 
 * SPDX-License-Identifier: LGPL-2.1-or-later
 *
 * Utility method for running post processing of component code before the image build
 */

def assemble(def projectInfo, def component) {
    // clean python workspace after scanner step complete
    sh """
        git clean -fxd

        sed -i '/^FROM.*/a ARG PIP_CONFIG_FILE=./${el.cicd.EL_CICD_BUILD_SECRETS_NAME}/pip.conf' Dockerfile
    """
}

return this