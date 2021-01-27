/* 
 * SPDX-License-Identifier: LGPL-2.1-or-later
 *
 * Utility method for running post processing of microservice code before the image build
 */

def package(def projectInfo, def microService) {
    // clean python workspace after scanner step complete
    sh """
        git clean -fxd

        sed -i 's|^FROM.*|a ARG PIP_CONFIG_FILE=./${el.cicd.EL_CICD_BUILD_SECRETS}/pip.conf|'
    """
}

return this