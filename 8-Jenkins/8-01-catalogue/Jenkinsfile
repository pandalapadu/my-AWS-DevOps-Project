@Library('roboshop-shared-library') _

def configMap = [
    component : 'catalogue',
    project   : 'roboshop',
    port      : 8080,
    isActive  : true
]

// Check if current branch is 'main' (ignoring case)
if (env.BRANCH_NAME?.equalsIgnoreCase('main')) {
    echo "we will build it later"
} else {
    nodejsEKSpipeline(configMap)
}