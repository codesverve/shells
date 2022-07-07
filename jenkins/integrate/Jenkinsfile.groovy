pipeline {
    agent any

    parameters {
        string description: '发版环境名', name: 'PROFILE', defaultValue: 'prod'
        string description: '发版后端代码分支', name: 'BACKEND_BRANCH_NAME', defaultValue: 'master'
        string description: '发版前端代码分支', name: 'FRONTEND_BRANCH_NAME', defaultValue: 'master'
        string description: '发版服务器IP', name: 'SERVER_IP', defaultValue: '172.10.1.2'
        string description: '发版服务器SSH端口', name: 'SERVER_PORT', defaultValue: '22'
        string description: '发版服务器密钥ID', name: 'SERVER_CREDENTIAL_ID', defaultValue: 'server1-credential-id'
        string description: '服务端口', name: "SERVICE_PORT", defaultValue: '8080'
        string description: 'JAVA启动参数', name: "EXT_JAVA_OPT", defaultValue: ''
    }

    environment {
        imageName = "uetty/iblog"
        backendSourceCodeHome = "$WORKSPACE/iblog"
        backendSourceCodeGit = "git@github.com:Uetty/blog.git"
        frontendSourceCodeHome = "$WORKSPACE/front-backend"
        frontendSourceCodeGit = "git@github.com:Uetty/adui-blog-website.git"
        gitCredentialId = "11112222-3333-4444-5555-666677778888"
        artifactPath = "$WORKSPACE/iblog/target/archive-blog.jar"
        dockerArtifactPath = "$WORKSPACE/iblog/docker/app.jar"
        dockerFilePath = "$WORKSPACE/iblog/docker/Dockerfile"
        dockerExecBase = "$WORKSPACE/iblog/docker/"
        dockerRepoIpPort = "172.10.1.1:8081"
        dockerRepoProtocal = "http://"
        dockerCredentialId = "dockerUser"
        startShellFilePath =  "$WORKSPACE/iblog/docker/runImage.sh"
    }

    tools {
        maven "Maven-3.6.3"
        nodejs "nodejs-12.22.8"
    }

    stages {

        stage('frontend checkout') {
            steps {

                dir(env.frontendSourceCodeHome) {
                    sh 'pwd'
                    sh 'ls'
                    sh 'echo'
                    sh 'echo "pull frontend sourcecode"'
                    git branch: params.FRONTEND_BRANCH_NAME, credentialsId: env.gitCredentialId, url: env.frontendSourceCodeGit
                    sh 'git status'
                    sh 'git branch'
                }
            }
        }

        stage('backend checkout') {
            steps {
                dir(env.backendSourceCodeHome) {
                    sh 'pwd'
                    sh 'ls'
                    sh 'echo'
                    sh 'echo "pull backend sourcecode"'
                    script {
                        def ex = fileExists "src/main/resources/static"
                        if (ex) {
                            sh 'rm -rf src/main/resources/static/*'
                        }
                    }
                    git branch: params.BACKEND_BRANCH_NAME, credentialsId: env.gitCredentialId, url: env.backendSourceCodeGit
                    sh 'git status'
                    sh 'git branch'
                }
            }
        }

        stage('build') {
            steps {
                script {
                    sh "set -ex"
                    sh 'echo '
                    sh 'pwd'

                    dir(env.frontendSourceCodeHome) {
                        def frontendCommitId = sh(script: 'git rev-parse --short=6 HEAD', returnStdout: true).trim()
                        env.frontendCommitId = frontendCommitId
                    }

                    dir(env.backendSourceCodeHome) {
                        def backendCommitId = sh(script: 'git rev-parse --short=6 HEAD', returnStdout: true).trim()
                        env.backendCommitId = backendCommitId
                    }

                    docker.withRegistry(env.dockerRepoProtocal + env.dockerRepoIpPort, env.dockerCredentialId) {

                        env.unionCommitId = env.backendCommitId + env.frontendCommitId

                        env.imageFullName = env.imageName + ":" + env.unionCommitId
                        env.remoteImageName = env.dockerRepoIpPort + "/" + env.imageName
                        env.remoteImageFullName = env.remoteImageName + ":" + env.unionCommitId

                        sh 'echo remoteImageName: ' + env.remoteImageName

                        def count = sh(script: 'docker search --limit 100 ' + env.remoteImageName + ' | grep ' + env.imageFullName + ' |wc -l', returnStdout: true).trim()
                        def built = count != '' && Integer.parseInt(count) > 0

                        // package project
                        sh 'echo imageExists: ' + built
                        if (!built) {

                            dir(env.frontendSourceCodeHome) {
                                sh 'echo run build frontend'
                                sh "npm install"
                                sh "npm run build"
                            }

                            dir(env.backendSourceCodeHome) {
                                sh 'rm -rf ' + env.backendSourceCodeHome + '/src/main/resources/static/*'
                                sh 'cp -rf ' + env.frontendSourceCodeHome + '/dist/* ' + env.backendSourceCodeHome + '/src/main/resources/static/'

                                sh 'mvn -U -e -DskipTests clean package'
                            }

                        } else {
                            sh 'echo image exist, skip package project'
                        }

                        if (!built) {
                            sh "cp " + env.artifactPath + "  " + env.dockerArtifactPath

                            sh 'echo ' + env.imageFullName

                            def image = docker.build(env.imageFullName ,"-f " + env.dockerFilePath + " " + env.dockerExecBase)
                            image.push()
                            sh "echo imageName: " + image.id + ", newImageName: " + image.imageName()

                            sh 'docker rmi ' + env.imageFullName
                            sh 'docker rmi ' + image.imageName()
                        } else {
                            sh 'echo image exist, skip build image'
                        }

                    }
                }
            }
        }

        stage('run docker') {
            steps {
                dir(env.backendSourceCodeHome) {
                    script {
                        // 使用 userName变量接收用户名，使用password变量接收密码
                        withCredentials([usernamePassword(credentialsId: params.SERVER_CREDENTIAL_ID, passwordVariable: 'password', usernameVariable: 'userName')]) {
                            def remote = [:]
                            remote.name = "remote-server"
                            remote.host = params.SERVER_IP
                            remote.port = Integer.parseInt(params.SERVER_PORT)
                            remote.allowAnyHosts = true
                            remote.user = userName
                            remote.password = password
                            // 将启动脚本文件发送到服务器
                            sshPut remote: remote, from: env.startShellFilePath, into: '/script/runImage.sh'

                            sshCommand remote: remote, command: 'chmod a+x /script/runImage.sh'

                            def baseShellOpt = '--type=master --profile=' + params.PROFILE + " --repo=" + env.dockerRepoIpPort + " --tag=" + env.unionCommitId
                            def shellOpt = baseShellOpt + ' --port=' + params.SERVICE_PORT + ' --image=\"' + env.imageName + '\"'
                            if (params.EXT_JAVA_OPT != '') {
                                shellOpt = shellOpt + ' --ext-opt=\"' + params.EXT_JAVA_OPT + '\"'
                            }
                            // 调用部署服务器上的脚本，执行部署更新
                            sshCommand remote: remote, command: '/script/runImage.sh ' + shellOpt

                        }
                    }
                }
            }
        }
    }
}
