/*
 * on-success-non-prod project test script
 */

def call(Map args) {
    loggingUtils.echoBanner("RUNNING IN THE EXAMPLE BUILD ARTIFACTS AND COMPONENTS PRE-USER-INPUT HOOK SCRIPT", "${args.projectInfo.id})
}

return this