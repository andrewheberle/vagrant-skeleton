# -*- mode: ruby -*-
# vi: set ft=ruby :

Vagrant.configure(2) do |config|
  config.vm.box = "bento/centos-6.7"

  config.vm.provision "shell" do |shell|
    shell.path = "shell/bootstrap.sh"
    shell.binary = false
  end

  config.vm.provision "puppet" do |puppet|
    puppet.environment = "bootstrap"
    puppet.environment_path = "puppet"
  end

end
