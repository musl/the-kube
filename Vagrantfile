# -*- mode: ruby -*-
# vi: set ft=ruby sw=2 ts=2 :

Vagrant.configure('2') do |config|
  config.vm.box = 'ubuntu/bionic64'

  config.vm.provider 'virtualbox' do |vb|
    vb.gui = false
    vb.memory = '4096'
  end

  config.vm.provision 'shell', inline: <<-SHELL
    wget https://raw.github.com/coreos/init/master/bin/coreos-install
    chmod 0755 coreos-install
    apt-get clean
    apt-get update
    apt-get install -y make
  SHELL

  config.vm.synced_folder '.', '/vagrant', disabled: false
end
