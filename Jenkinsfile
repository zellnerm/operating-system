node {
   stage('Preparation') { // for display purposes
      sh "make clean"
      sh "rm -rf log"
      // Get some code from a GitHub repository
      // Could possibly be obsolete, will further investigate when isnan/inf bug is fixed
      checkout scm
      //git branch: 'master', url: 'https://github.com/argos-research/operating-system.git'  
      //git submodule init
      //git submodule update
      //Preparing build
      sh "wget https://nextcloud.os.in.tum.de/s/KVfFOeRXVszFROl/download --no-check-certificate -O libports.tar.bz2"
      sh "tar xvjC genode/ -f libports.tar.bz2"
      sh "mkdir -p log"
      sh "touch log/prepare.log"
      sh "make > log/prepare.log 2>&1"
      sh "touch log/make.log"
   }
   stage('Build') {
      // Run the build of dom0-HW
      sh "make run > log/make.log 2>&1"
   }
   stage('Notifications') {
      sh "mkdir -p /home/bliening/ownCloud/702nados/log/${env.JOB_NAME}/${env.BUILD_NUMBER}"
      sh "cp -R log/* /home/bliening/ownCloud/702nados/log/${env.JOB_NAME}/${env.BUILD_NUMBER}/"
      mattermostSend color: "#439FE0", message: "Build Finished: ${env.JOB_NAME} ${env.BUILD_NUMBER}"
      // should be with specific channel
      
   }
   //Here tests or other stuff would appear
}
