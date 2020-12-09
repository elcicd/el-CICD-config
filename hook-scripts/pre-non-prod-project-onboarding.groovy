/*
 * Pre-non-prod project onboarding test script.
 */

def call(Map args) {
    dir (el.cicd.PROJECT_DEFS_DIR) {
        sh "cp ${args.projectId}.yml ${args.projectId}-test.yml"

        withCredentials([sshUserPrivateKey(credentialsId: el.cicd.EL_CICD_PROJECT_INFO_REPOSITORY_READ_ONLY_GITHUB_PRIVATE_KEY_ID, keyFileVariable: 'GITHUB_PRIVATE_KEY')]) {
            sh """
                #git add ${el.cicd.PROJECT_DEFS_DIR}/${args.projectId}.yml
                #git config user.name "el-CICD"
                #git config user.email "${el.cicd.DEVOPS_EMAIL_LIST}"
                #git commit -am 'writing el-CICD-config Project Definition File for ${args.projectId}'
                ${sshAgentBash GITHUB_PRIVATE_KEY,
                               "git add ${args.projectId}-test.yml",
                               "git commit -am \"writing el-CICD-config Project Definition File for ${args.projectId}-test\"",
                               "git push --set-upstream origin development"}
            """
        }
    }
}

return this