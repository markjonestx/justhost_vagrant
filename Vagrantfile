# -*- mode: ruby -*-
# vi: set ft=ruby :

# Vagrantfile API/syntax version. Don't touch unless you know what you're doing!
VAGRANTFILE_API_VERSION = "2"

Vagrant.configure(VAGRANTFILE_API_VERSION) do |config|
  # CentOS 6 Box
  config.vm.box = "centos/6"
  config.ssh.insert_key = false
  config.vm.synced_folder ".", "/vagrant", type: "virtualbox"

  # Forward port 80 to the host
  config.vm.network "forwarded_port", guest: 80, host: 8080
  config.vm.provider "virtualbox" do |vb|
    # Set 2G of System memory and 2 CPUs for development
    vb.customize ["modifyvm", :id, "--memory", "2048"]
    vb.customize ["modifyvm", :id, "--cpus", "2"]
  end

 config.vm.provision "shell", path: "provision_script.sh"
 config.vm.provision :reload
end
