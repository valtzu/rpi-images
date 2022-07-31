Vagrant.configure("2") do |config|
  config.vm.box = "ubuntu/jammy64"
  config.vm.provider :virtualbox do |v|
    v.customize ["modifyvm", :id, "--uart1", "0x3F8", "4"]
    v.customize ["modifyvm", :id, "--uartmode1", "file", File::NULL]
  end
  config.vm.provision:shell, inline: <<-SHELL
    apt-get update
    apt-get install -y make wget xz-utils qemu-user-static
    curl -L https://proot.gitlab.io/proot/bin/proot > /usr/bin/proot
    chmod +x /usr/bin/proot
    proot --version
  SHELL
end
