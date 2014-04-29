require 'thor'
require 'yaml'
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

    private

    def load_proxmoxrc
      puts "Loading #{ENV['HOME']}/.proxmoxrc"
      begin
        File.read("#{ENV['HOME']}/.proxmoxrc")
      rescue Errno::ENOENT
        puts "Proxmox config not found. Use 'proxmox config' to create it."
        exit
      end
    end
  end
end
