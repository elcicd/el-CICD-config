/* 
 * SPDX-License-Identifier: LGPL-2.1-or-later
 *
 * Utility method for deploying a artifact to an artifact repository
 */

def deploy(def projectInfo, def artifact) {
    echo 'WARNING: artifact deployments not currently enabled for Python builds'

    // if (artifact.type == 'EGG') {
    //     sh 'python setup.py sdist upload -r local'
    // }
    // else {
    //     sh 'python setup.py bdist_wheel upload -r local'
    // }
}

return this