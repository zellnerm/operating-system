node {
   stage('Preparation') { // for display purposes
      // Get some code from a GitHub repository
      // Could possibly be obsolete, will further investigate when isnan/inf bug is fixed
      git branch: 'master', url: 'https://github.com/argos-research/operating-system.git'  
      git submodule init
      git submodule update
      //Preparing build
      //sh "make"
   }
   stage('Build') {
      // Run the build of dom0-HW
      sh "make run"
   }
   //Here tests or other stuff would appear
}
