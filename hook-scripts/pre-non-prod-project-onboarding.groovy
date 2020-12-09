/*
 * Pre-non-prod project onboarding test script.
 */

def call(Map args) {
    def projectInfo = args.projectInfo
    dir (el.cicd.PROJECT_DEFS_DIR) {
        sh "cp ${projectInfo.id}.yml ${projectInfo.id}-test.yml"

        withCredentials([sshUserPrivateKey(credentialsId: el.cicd.EL_CICD_PROJECT_INFO_REPOSITORY_READ_ONLY_GITHUB_PRIVATE_KEY_ID, keyFileVariable: 'GITHUB_PRIVATE_KEY')]) {
            sh """
                #git add ${el.cicd.PROJECT_DEFS_DIR}/${projectInfo.id}.yml
                #git config user.name "el-CICD"
                #git config user.email "${el.cicd.DEVOPS_EMAIL_LIST}"
                #git commit -am 'writing el-CICD-config Project Definition File for ${projectInfo.id}'
                ${sshAgentBash GITHUB_PRIVATE_KEY,
                               "git config --global user.name \"el-CICD\"",
                               "git config --global user.email \"${el.cicd.DEVOPS_EMAIL_LIST}\"",
                               "git add ${projectInfo.id}.yml",
                               "git commit -am \"writing el-CICD-config Project Definition File for ${projectInfo.id}\"",
                               "git push --set-upstream origin development"}
            """
        }
    }
}

return this