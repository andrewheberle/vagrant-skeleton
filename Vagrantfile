# -*- mode: ruby -*-
# vi: set ft=ruby :

Vagrant.configure(2) do |config|
  config.vm.box = "bento/centos-7.1"

  config.vm.provision "shell" do |shell|
    shell.path = "shell/bootstrap.sh"
  end

  config.vm.provision "puppet" do |puppet|
    puppet.environment = "bootstrap"
    puppet.environment_path = "puppet"
  end

end
