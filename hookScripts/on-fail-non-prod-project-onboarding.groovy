
def call(def exception) {
    echo exception

    pipelineUtils.choBanner("WE'RE IN THE FAIL SCRIPT: ${exception?.getMessage()} !!!!!!")
}

return this