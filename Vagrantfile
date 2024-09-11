Vagrant.configure("2") do |config|
  config.ssh.password = "vagrant"

  config.vm.box = "altf4llc/debian-bookworm"

  # Speed is important here as a lot of compiling is done in the vm
  # Be sure to set a high enough value for your system
  config.vm.provider :vmware_desktop do |vmware|
    vmware.vmx["memsize"] = "8192"
    vmware.vmx["numvcpus"] = "8"
  end

  config.vm.provision "shell", keep_color: true, privileged: false, inline: <<-SHELL
    echo 'function sync_sandbox {
      pushd "${HOME}"

      mkdir -p ./vorpal-sandbox

      rsync -aPW \
        --exclude=".env" \
        --exclude=".git" \
        --exclude=".vagrant" \
        --exclude="dist" \
        --exclude="packer_debian_vmware_arm64.box" \
        /vagrant/. ./vorpal-sandbox/.

      popd
    }' >> ~/.bashrc

    echo 'function build_sandbox {
      sync_sandbox

      pushd "${HOME}/vorpal-sandbox"

      ./script/debian.sh

      make dist

      popd
    }' >> ~/.bashrc
  SHELL
end
