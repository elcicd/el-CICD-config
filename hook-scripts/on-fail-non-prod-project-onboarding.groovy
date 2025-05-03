/*
 * on-fail-non-prod project test script
 */

def call(def exception, Map args) {
    loggingUtils.echoBanner("RUNNING IN THE EXAMPLE PROJECT ONBOARDING FAILED WITH EXCEPTION SCRIPT: ${exception}")
}

return this