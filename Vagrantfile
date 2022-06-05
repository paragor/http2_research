# -*- mode: ruby -*-
# # vi: set ft=ruby :

$clientScript = <<-'SCRIPT'
set -ex
sudo apt update && sudo apt install -y jq iperf3

sudo cp -r /tmp/sysctl_toggle.sh /usr/bin/sysctl_toggle.sh
sudo chmod +x /usr/bin/sysctl_toggle.sh

cd /tmp/
sudo mkdir -p /root/.ssh/
sudo cp -r /tmp/ssh/* /root/.ssh/
sudo chmod 600 /root/.ssh/*
wget 'https://github.com/tsenart/vegeta/releases/download/v12.8.4/vegeta_12.8.4_linux_amd64.tar.gz'
tar xvzf vegeta_12.8.4_linux_amd64.tar.gz
chmod +x vegeta
sudo cp vegeta /usr/bin
wget "https://github.com/grafana/k6/releases/download/v0.38.3/k6-v0.38.3-linux-amd64.tar.gz"
tar --strip-components 1 -xvzf k6-v0.38.3-linux-amd64.tar.gz
sudo chmod +x k6
sudo cp k6 /usr/bin
SCRIPT

$serverScript = <<-'SCRIPT'
set -ex
sudo apt update && sudo apt install -y nginx jq iperf3
ls /tmp/*
sudo cp /tmp/server/resources/content.jpeg /var/www/html/content.jpeg
sudo cp -r /tmp/server/nginx/* /etc/nginx/
sudo cp -r /tmp/sysctl_toggle.sh /usr/bin/sysctl_toggle.sh
sudo mkdir -p /root/.ssh/
sudo cp /tmp/ssh/id_rsa.pub /root/.ssh/authorized_keys
sudo chmod 600 /root/.ssh/authorized_keys
sudo chmod +x /usr/bin/sysctl_toggle.sh
sudo nginx -t
sudo nginx -s reload
sudo iptables -I INPUT -m statistic --mode random --probability 0.2 -j DROP
SCRIPT


Vagrant.require_version ">= 2.0.0"
servers=[
  {
    :hostname => "server",
    :ip => "192.168.100.10",
    :box => "generic/ubuntu2004",
    :ram => 2048,
    :cpu => 2,
    :script => $serverScript,
    :files => [
        {
            :src => "server/",
            :dst => "/tmp/"
        },
        {
            :src => "ssh/",
            :dst => "/tmp/"
        },
        {
            :src => "sysctl_toggle.sh",
            :dst => "/tmp/sysctl_toggle.sh"
        },
    ],
  },
  {
    :hostname => "client",
    :ip => "192.168.100.11",
    :box => "generic/ubuntu2004",
    :ram => 2048,
    :cpu => 2,
    :script => $clientScript,
    :files => [
        {
            :src => "sysctl_toggle.sh",
            :dst => "/tmp/sysctl_toggle.sh"
        },
        {
            :src => "ssh/",
            :dst => "/tmp/"
        },
        {
            :src => "client/",
            :dst => "/tmp/"
        },
    ],
  }
]


Vagrant.configure("2") do |config|
    servers.each do |machine|
        config.vm.define machine[:hostname] do |node|
            node.vm.box = machine[:box]
            node.vm.hostname = machine[:hostname]
            node.vm.network "private_network", ip: machine[:ip]
            node.ssh.username = 'vagrant'

            node.vm.provider "virtualbox" do |vb|
                vb.memory = machine[:ram]
                vb.cpus = machine[:cpu]
                vb.gui = false
                vb.customize ["modifyvm", :id, "--audio", "none"]
            end

            machine[:files].each do |f|
                config.vm.provision "file", source: f[:src], destination: f[:dst]
            end

            node.vm.provision "shell", inline: machine[:script]

        end
    end
end
