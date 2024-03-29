/* 
 * SPDX-License-Identifier: LGPL-2.1-or-later
 *
 * Utility method for running Python pytest based unit tests
 */

def test(def projectInfo, def component) {
    sh """
        if [[ -f ${el.cicd.BUILDER_SECRETS_DIR}/pip.conf ]]
        then
            PIP_CONFIG_FILE=${el.cicd.BUILDER_SECRETS_DIR}/pip.conf
        fi

        mkdir -p ./tests
        if [[ `ls -l ./tests/*.py | wc -l` -gt 0 ]]
        then
            virtualenv ./venv
            source ./venv/bin/activate
            # if using artifact repository for caching:
            # PIP_HOST=http://svc_acct_username:svc_acct_token@https://artifact.repository.com/artifact repository/python/artifacts
            python -m pip install wheel pytest coverage -r ./requirements.txt
            python -m coverage run --omit './venv/*' -m pytest ./tests
            python -m coverage xml -o ./coverage.xml
            deactivate
        else
            ${shCmd.echo 'No Python tests found in tests directory'}
        fi
    """
}

return this