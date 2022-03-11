Vagrant.configure("2") do |config|
  config.vm.box = "bento/ubuntu-20.04"
  config.vm.provision:shell, inline: <<-SHELL
    apt-get update
    apt-get install -y make wget xz-utils proot qemu-user-static
  SHELL
end
