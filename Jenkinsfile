pipeline {
    agent {
        label "prod"
    }
    options {
        buildDiscarder(logRotator(numToKeepStr: '2'))
        disableConcurrentBuilds()
    }
    parameters {
        string(
                name: "scale",
                defaultValue: "1",
                description: "The number of nodes to add or remove"
        )
        string(
                name: "asg_name",
                defaultValue: "",
                description: "The ASG name"
        )
    }
    stages {
        stage("scale") {
            steps {

                if ("${asg_name}" == "") {
                  currentBuild.result = 'ABORTED'
                  error('Stopping early… No asg_name passed')
                }

                script {
                    def asgDesiredCapacity = sh(
                            script: "REGION=${REGION} ASG_NAME=${asg_name} docker-compose run --rm asg-desired-capacity",
                            returnStdout: true
                    ).trim().toInteger()
                    def asgNewCapacity = asgDesiredCapacity + scale.toInteger()
                    if (asgNewCapacity < 1) {
                        error "The number of nodes is already at the minimum capacity of 1"
                    } else if (asgNewCapacity > 3) {
                        error "The number of nodes is already at the maximum capacity of 3"
                    } else {
                        sh "REGION=${REGION} ASG_NAME=${asg_name} ASG_DESIRED_CAPACITY=${asgNewCapacity} docker-compose run --rm asg-update-desired-capacity"
                        if (scale.toInteger() > 0) {
                            sleep 300
                            script {
                                def servicesOut = sh(
                                        script: "docker service ls -q -f label=com.df.reschedule=true",
                                        returnStdout: true
                                )
                                def services = servicesOut.split('\n')
                                def date = new Date()
                                for(int i = 0; i < services.size(); i++) {
                                    def service = services[0]
                                    sh "docker service update --env-add 'RESCHEDULE_DATE=${date}' ${service}"
                                }
                            }
                        }
                        echo "Changed the number of ${asg_name} nodes from ${asgDesiredCapacity} to ${asgNewCapacity}"
                    }
                }
            }
        }
    }
    post {
        success {
            slackSend(
                    color: "good",
                    message: """Scaled the number of \"${asg_name}\" nodes.
Please check Jenkins logs for the job ${env.JOB_NAME} #${env.BUILD_NUMBER}
${env.BUILD_URL}console"""
            )
        }
        failure {
            slackSend(
                    color: "danger",
                    message: """Unable to scale the number of \"${asg_name}\" nodes.
Please check Jenkins logs for the job ${env.JOB_NAME} #${env.BUILD_NUMBER}
${env.BUILD_URL}console"""
            )
        }
    }
}
