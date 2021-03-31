/* 
 * SPDX-License-Identifier: LGPL-2.1-or-later
 *
 * Utility method for deploying a library to an artifact repository
 */

def assemble(def projectInfo, def library) {
    echo 'WARNING: library deployments not currently enabled for Java Maven builds'

    // sh 'mvn -DskipTests --batch-mode deploy'
}

return this