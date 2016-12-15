node {
   stage('Preparation') { // for display purposes
      sh "rm -rf build"
      sh "rm -rf genode/contrib"
      // Get some code from a GitHub repository
      // Could possibly be obsolete, will further investigate when isnan/inf bug is fixed
      checkout scm
      //git branch: 'master', url: 'https://github.com/argos-research/operating-system.git'  
      //git submodule init
      //git submodule update
      //Preparing build
      sh "make"
   }
   stage('Build') {
      // Run the build of dom0-HW
      sh "make run"
   }
   stage('Notifications') {
      mattermostSend color: "#439FE0", message: "Build Finished: ${env.JOB_NAME} ${env.BUILD_NUMBER}"
   }
   //Here tests or other stuff would appear
}
