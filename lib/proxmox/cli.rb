require 'thor'
require 'proxmox'

module Proxmox
  class CLI < Thor
    desc "config", "Create proxmox config file"
    def config
      puts "Creating config file..."
      File.open("~/.proxmoxrc", "w") do |file|
        file.write "Testing..."
      end
    end
    private

    def load_proxmoxrc
      puts "Loading ~/.proxmoxrc"
    end
  end
end
