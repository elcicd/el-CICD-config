/* 
 * SPDX-License-Identifier: LGPL-2.1-or-later
 *
 * Utility method for deploying a library to an artifact repository
 */

def deploy(def projectInfo, def library) {
    echo 'WARNING: library deployments not currently enabled for Python builds'

    // if (library.type == 'EGG') {
    //     sh 'python setup.py sdist upload -r local'
    // }
    // else {
    //     sh 'python setup.py bdist_wheel upload -r local'
    // }
}

return this