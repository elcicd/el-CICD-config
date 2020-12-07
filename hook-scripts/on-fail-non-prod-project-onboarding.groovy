
def call(Map args, def exception) {
    pipelineUtils.echoBanner("WE'RE IN THE FAIL SCRIPT: ${exception?.getMessage()} !!!!!!")
}

return this