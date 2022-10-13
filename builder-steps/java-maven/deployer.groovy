/* 
 * SPDX-License-Identifier: LGPL-2.1-or-later
 *
 * Utility method for deploying a artifact to an artifact repository
 */

def deploy(def projectInfo, def artifact) {
    echo 'WARNING: artifact deployments not currently enabled for Java Maven builds'

    // sh 'mvn -DskipTests --batch-mode deploy'
}

return this