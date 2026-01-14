pipeline {
  agent any

  environment {
    IMAGE_NAME = "ansible-control:local"
    SSH_DIR    = "/opt/ansible_docker_ssh"
    INVENTORY  = "inventories/prod/hosts.yml"
    PLAYBOOK   = "playbooks/site.yml"
  }

  stages {

    stage('Show Workspace') {
      steps {
        sh '''
          pwd
          ls -al
        '''
      }
    }

    stage('Build Ansible Image') {
      steps {
        sh 'docker build -t ${IMAGE_NAME} .'
      }
    }

    stage('Syntax Check') {
      steps {
        sh '''
          docker run --rm \
            -v ${SSH_DIR}:/root/.ssh:ro \
            ${IMAGE_NAME} \
            ansible-playbook -i ${INVENTORY} ${PLAYBOOK} --syntax-check
        '''
      }
    }

    stage('Dry Run (ai_worker)') {
      steps {
        sh '''
          docker run --rm \
            -v ${SSH_DIR}:/root/.ssh:ro \
            ${IMAGE_NAME} \
            ansible-playbook \
              -i ${INVENTORY} \
              ${PLAYBOOK} \
              --check --diff -l ai_worker
        '''
      }
    }

    stage('🚨 Approve Deploy') {
      steps {
        input message: '''
Dry Run이 정상적으로 끝났습니다.
👉 실제 배포를 진행하시겠습니까?
'''
      }
    }
  }
}
