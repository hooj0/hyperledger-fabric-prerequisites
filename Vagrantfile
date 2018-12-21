# -*- mode: ruby -*-
# vi: set ft=ruby :
# Copyright IBM Corp All Rights Reserved
#
# SPDX-License-Identifier: Apache-2.0
#
# This vagrantfile creates a VM with the development environment
# configured and ready to go.
#
# The setup script (env var $script) in this file installs docker.
# This is not in the setup.sh file because the docker install needs
# to be secure when running on a real linux machine.
# The docker environment that is installed by this script is not secure,
# it depends on the host being secure.
#
# At the end of the setup script in this file, a call is made
# to run setup.sh to create the developer environment.

# This is the mount point for the sync_folders of the source
SRCMOUNT = "/hyperledger"
LOCALDEV = "/local-dev"

$script = <<SCRIPT
set -x

echo "127.0.0.1 couchdb" | tee -a /etc/hosts

cd #{SRCMOUNT}/fabric/devenv
./setup.sh

SCRIPT

Vagrant.require_version ">= 1.7.4"
Vagrant.configure('2') do |config|
  config.vm.box = "ubuntu/xenial64"
  
  #config.ssh.username = 'root'
  #config.ssh.password = 'vagrant'
  #config.ssh.insert_key = 'true'

  #config.vm.network "private_network", ip: "192.168.8.8"
  config.vm.network "private_network", ip: "192.168.99.100"
  
  #config.vm.network :forwarded_port, guest: 7050, host: 7050, id: "orderer", host_ip: "localhost", auto_correct: true # fabric orderer service
  #config.vm.network :forwarded_port, guest: 2333, host: 2333, protocol: "tcp" # dockerd
  
  
  config.vm.synced_folder "../..", "#{SRCMOUNT}"
  config.vm.synced_folder "../..", "/opt/gopath/src/github.com/hyperledger"
  
  #config.vm.synced_folder "G:/docker-data", "/mnt/data/docker", owner: "root", group: "root"
  config.vm.synced_folder "D:/.m2/repository", "/root/.m2/repository"
  config.vm.synced_folder "D:/workspace_fabric", "/opt/fabric-dev"
  config.vm.synced_folder "D:/workspace_blockchain_masget", "/opt/fabric-prod"
  
  config.vm.synced_folder "D:/workspace_fabric/fabric-sdk-java/src/test/fixture/sdkintegration", "/opt/gopath/src/github.com/hyperledger/fabric/sdkintegration"
  #config.vm.synced_folder "D:/workspace_fabric/fabric-sdk-integrate/src/test/fixture/integration", "/opt/gopath/src/github.com/hyperledger/fabric/integration"
  #config.vm.synced_folder "D:/workspace_fabric/fabric-sdk-commons/src/test/fixture/integration", "/opt/gopath/src/github.com/hyperledger/fabric/integration"
  #config.vm.synced_folder "D:/workspace_fabric/fabric-sdk-spring/spring-data-fabric-chaincode/src/test/fixture/integration","/opt/gopath/src/github.com/hyperledger/fabric/integration"
  #config.vm.synced_folder "D:/workspace_fabric/fabric-sdk-spring/spring-data-fabric-chaincode-examples/src/main/resources/fabric-integration","/opt/gopath/src/github.com/hyperledger/fabric/integration"  
  #config.vm.synced_folder "D:/workspace_blockchain_masget/blockchain-fabric-chaincode/chaincode-deploy-service/src/fabric/resources","/opt/gopath/src/github.com/hyperledger/fabric/integration"
  #config.vm.synced_folder "D:/workspace_blockchain_masget/blockchain-fabric-network/dev/simple","/opt/gopath/src/github.com/hyperledger/fabric/integration"
  
  
  config.vm.synced_folder ENV.fetch('LOCALDEVDIR', "../.."), "#{LOCALDEV}"
  config.vm.provider :virtualbox do |vb|
    vb.name = "hyperledger"
    vb.customize ['modifyvm', :id, '--memory', '4096']
    vb.cpus = 2

    storage_backend = ENV['DOCKER_STORAGE_BACKEND']
    case storage_backend
    when nil,"","aufs","AUFS"
      # No extra work to be done
    when "btrfs","BTRFS"
      # Add a second disk for the btrfs volume
      IO.popen("VBoxManage list systemproperties") { |f|

        success = false
        while line = f.gets do
          # Find the directory where the machine images are stored
          machine_folder = line.sub(/^Default machine folder:\s*/,"")

          if line != machine_folder
            btrfs_disk = File.join(machine_folder, vb.name, 'btrfs.vdi')

            unless File.exist?(btrfs_disk)
              # Create the disk if it doesn't already exist
              vb.customize ['createhd', '--filename', btrfs_disk, '--format', 'VDI', '--size', 20 * 1024]
            end

            # Add the disk to the VM
            vb.customize ['storageattach', :id, '--storagectl', 'SATA Controller', '--port', 1, '--device', 0, '--type', 'hdd', '--medium', btrfs_disk]
            success = true

            break
          end
        end
        raise Vagrant::Errors::VagrantError.new, "Could not provision btrfs disk" if !success
      }
    else
      raise Vagrant::Errors::VagrantError.new, "Unknown storage backend type: #{storage_backend}"
    end

  end

  config.vm.provision :shell, inline: $script
end
