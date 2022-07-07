pipeline {
    agent any

    parameters {
        string description: '发版环境名', name: 'PROFILE', defaultValue: 'prod'
        string description: '发版代码分支', name: 'BRANCH_NAME', defaultValue: 'master'
        string description: '发版服务器IP', name: 'SERVER_IP', defaultValue: '172.10.1.2'
        string description: '发版服务器SSH端口', name: 'SERVER_PORT', defaultValue: '22'
        string description: '发版服务器密钥ID', name: 'SERVER_CREDENTIAL_ID', defaultValue: 'server1-credential-id'
        string description: '服务端口', name: "SERVICE_PORT", defaultValue: '6060'
    }

    environment {
        imageName = "uetty/frontend-iblog"
        sourceCodeHome = "$WORKSPACE/iblog-ui"
        sourceCodeGit = "git@github.com:Uetty/adui-blog-website.git"
        gitCredentialId = "44444444-ffff-eeee-dddd-aaaabbbbcccc"
        artifactPath = "$WORKSPACE/iblog-ui/dist"
        dockerArtifactPath = "$WORKSPACE/iblog-ui/docker/app.tar"
        dockerFilePath = "$WORKSPACE/iblog-ui/docker/Dockerfile"
        dockerExecBase = "$WORKSPACE/iblog-ui/docker/"
        dockerRepoIpPort = "172.10.1.1:8081"
        dockerRepoProtocal = "http://"
        dockerCredentialId = "dockerUser"
        startShellFilePath =  "$WORKSPACE/iblog-ui/docker/runImage.sh"
    }

    tools {
      nodejs "nodejs-12.22.8"
    }

    stages {

      stage('frontend checkout') {
        steps {

          dir(env.sourceCodeHome) {
            sh 'pwd'
            sh 'ls'
            sh 'echo'
            sh 'echo "pull sourcecode"'
            git branch: params.BRANCH_NAME, credentialsId: env.gitCredentialId, url: env.sourceCodeGit
            sh 'git status'
            sh 'git branch'
          }
        }
      }

      stage('frontend package') {
        steps {
          dir(env.sourceCodeHome) {
            script {
              sh 'pwd'
              sh 'ls'
              sh "set -ex"
              sh "echo "
              sh 'echo run build frontend'

              docker.withRegistry(env.dockerRepoProtocal + env.dockerRepoIpPort, env.dockerCredentialId) {

                def commitId = sh(script: 'git rev-parse --short=8 HEAD', returnStdout: true).trim()
                env.commitId = commitId

                env.imageFullName = env.imageName + ":" + commitId
                env.remoteImageName = env.dockerRepoIpPort + "/" + env.imageName
                env.remoteImageFullName = env.remoteImageName + ":" + commitId

                sh 'echo remoteImageName: ' + env.remoteImageName

                def count = sh(script: 'docker search ' + env.remoteImageName + ' | grep ' + env.imageFullName + ' |wc -l', returnStdout: true).trim()
                def built = count != '' && Integer.parseInt(count) > 0

                // package project
                sh 'echo imageExists: ' + built
                if (!built) {
                  sh "npm install"
                  sh "npm run build"
                } else {
                  sh 'echo image exist, skip build package project'
                }

                if (!built) {

                  sh 'tar -cf ' + env.dockerArtifactPath + ' -C ' + env.artifactPath + ' .'

                  sh 'echo ' + env.imageFullName

                  def image = docker.build(env.imageFullName, "-f " + env.dockerFilePath + " " + env.dockerExecBase)
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
      }

      stage('run docker') {
        steps {
          dir(env.sourceCodeHome) {
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

                def shellOpt = '--type=master --profile=' + params.PROFILE + " --repo=" + env.dockerRepoIpPort + " --tag=" + env.commitId

                shellOpt = shellOpt + ' --port=' + params.SERVICE_PORT + ' --image=' + env.imageName
                // 调用部署服务器上的脚本，执行部署更新
                sshCommand remote: remote, command: '/script/runImage.sh ' + shellOpt

              }
            }
          }
        }
      }
    }
}
