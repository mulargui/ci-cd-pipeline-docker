# -*- mode: ruby -*-
# vi: set ft=ruby :

#Add "C:\Program Files (x86)\HashiCorp\Vagrant\embedded\bin\" to the path at the end
#remember to include guest additions
#vagrant plugin install vagrant-vbguest or vagrant plugin update

VAGRANTFILE_API_VERSION = "2"

Vagrant.configure(VAGRANTFILE_API_VERSION) do |config|

	config.vm.box_check_update = false
	# Every Vagrant virtual environment requires a box to build off of.
	config.vm.box = "ubuntu/trusty64"
	
	# Provider-specific configuration
	config.vm.provider "virtualbox" do |vb|
		vb.name = "dev"
		vb.memory = 3072
	end
 
	# Create a forwarded port mapping 
	config.vm.network "forwarded_port", guest: 8080,  host: 8080 		# UI
	config.vm.network "forwarded_port", guest: 50000,  host: 50000 		# communication with slaves

	# provisioning using a shell script
	config.vm.provision "base", type: "shell", path: "./util/ctool.sh", args: "ALL"
	# config.vm.provision "apps", type: "shell", path: "./util/ctool.sh", args: "JENKINS", run: "always" #doesn't work, vagrant uses root for provisioning
end
