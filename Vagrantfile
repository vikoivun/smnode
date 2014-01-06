# -*- mode: ruby -*-
# vi: set ft=ruby :

# Vagrant configuration for testing automatic Ansible deployment of
# Helsinki Service Map cluster servers. This is a development tool, vagrant
# is not used for the actual deployment.

# Vagrantfile API/syntax version. Don't touch unless you know what you're doing!
VAGRANTFILE_API_VERSION = "2"

Vagrant.configure(VAGRANTFILE_API_VERSION) do |config|
  # Ubuntu version codename to use a base, following configuration will
  # download the image for this release
  ubuntu_version = "raring"
  # Addresses on the host-internal network, used for control and testing
  # cluster communication
  master_ip_address = "192.168.107.2"
  standby_ip_address = "192.168.107.3"

  config.vm.box = "#{ubuntu_version}-server64"
  config.vm.box_url ="http://cloud-images.ubuntu.com/vagrant/#{ubuntu_version}/current/#{ubuntu_version}-server-cloudimg-amd64-vagrant-disk1.box"

  # This prevents passing of locale configuration over SSH to the managed
  # host. This is due to many Debian packages failing to configure if they
  # are installed with non-fuctioning locale settings (such as unknown
  # locale passed from the control station)
  $script = <<SCRIPT
    grep -v -e "^AcceptEnv" /etc/ssh/sshd_config > /etc/ssh/sshd_config.new
    mv /etc/ssh/sshd_config.new /etc/ssh/sshd_config
    service ssh reload
SCRIPT

  config.vm.provider :virtualbox do |vb|
     # Don't boot with headless mode, uncomment for debugging
     #vb.gui = true

     # OVF container cannot (?) specify this, causing the ubuntu64-image to
     # fail on hosts with 32-bit kernel, but capable of hosting 64-bit guests
     vb.customize ["modifyvm", :id, "--ostype", "Ubuntu_64"]
  end

  config.vm.provision "shell", inline: $script

  config.vm.define "master" do |master|
    master.vm.network "private_network", ip: master_ip_address
    master.vm.hostname = "master"
    # Port-forwards from 8080 -> 80, for quick checks on web services
    master.vm.network :forwarded_port, guest: 80, host: 8080

    master.vm.provision "ansible" do |ansible|
      ansible.playbook = "deployment/site.yml"
      ansible.extra_vars = { app_user: "vagrant" }
      ansible.host_key_checking = false
      ansible.inventory_path = "deployment/testing_vagrant"
      ansible.limit = "sm_master"
      #ansible.verbose = "v"
    end
  end

  config.vm.define "standby" do |standby|
    standby.vm.network "private_network", ip: standby_ip_address
    standby.vm.hostname = "standby"
    # Port-forwards from 8081 -> 80, for quick checks on web services
    standby.vm.network :forwarded_port, guest: 80, host: 8081

    standby.vm.provision "ansible" do |ansible|
      ansible.playbook = "deployment/site.yml"
      ansible.extra_vars = { app_user: "vagrant" }
      ansible.host_key_checking = false
      ansible.inventory_path = "deployment/testing_vagrant"
      ansible.limit = "sm_standbys"
      #ansible.verbose = "v"
    end
  end
end
