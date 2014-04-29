require 'thor'
require 'yaml'
require 'awesome_print'
require 'proxmox'

module Proxmox
  class CLI < Thor
    desc 'config', 'Create proxmox config file'
    def config
      puts 'Creating config file...'
      config = {}
      defaults = {
        'api_url' => 'https://proxmox:8006/api2/json/',
        'node_name' => 'node',
        'user' => 'root',
        'password' => 'secret',
        'realm' => 'pam'
      }

      print "Proxmox api url (#{defaults['api_url']}): "
      config['api_url'] = $stdin.gets.chomp
      config['api_url'] = defaults['api_url'] if config['api_url'] == ""

      print "Proxmox node name (#{defaults['node_name']}): "
      config['node_name'] = $stdin.gets.chomp
      config['node_name'] = defaults['node_name'] if config['node_name'] == ""

      print "Proxmox user (#{defaults['user']}): "
      config['user'] = $stdin.gets.chomp
      config['user'] = defaults['user'] if config['user'] == ""

      print "Proxmox password (#{defaults['password']}): "
      config['password'] = $stdin.gets.chomp
      config['password'] = defaults['password'] if config['password'] == ""

      print "Proxmox realm (#{defaults['realm']}): "
      config['realm'] = $stdin.gets.chomp
      config['realm'] = defaults['realm'] if config['realm'] == ""

      File.open("#{ENV['HOME']}/.proxmoxrc", 'w') do |file|
        file.write config.to_yaml
      end

      puts "Saved to #{ENV['HOME']}/.proxmoxrc"
    end

    desc "templates", "Show available container templates"
    def templates
      config = load_proxmoxrc
      proxmox = authenticate(config)

      ap proxmox.templates
    end

    private

    def load_proxmoxrc
      puts "Loading #{ENV['HOME']}/.proxmoxrc"
      begin
        YAML.load(File.read("#{ENV['HOME']}/.proxmoxrc"))
      rescue Errno::ENOENT
        puts "Proxmox config not found. Use 'proxmox config' to create it."
        exit
      end
    end

    def authenticate(config)
      Proxmox.new(config['api_url'],
                  config['node_name'],
                  config['user'],
                  config['password'],
                  config['realm'])
    end
  end
end
