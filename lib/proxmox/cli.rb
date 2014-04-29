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
      config['password'] = $stdin.noecho(&:gets).chomp
      config['password'] = defaults['password'] if config['password'] == ""
      puts "\n"

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

    desc "openvz_create", "Creates an OpenVZ container"
    option :ostemplate, :aliases => "-t"
    option :vmid, :aliases => "-v"
    option :hostname, :aliases => "-h"
    option :password, :aliases => "-p"
    option :ip_address, :aliases => "-i"
    option :cpus, :aliases => "-c"
    option :memory, :aliases => "-m"
    option :swap, :aliases => "-s"
    def openvz_create
      config = load_proxmoxrc
      proxmox = authenticate(config)
      ostemplate = options[:ostemplate]
      vmid = options[:vmid]
      optional_config = {}

      options.each do |key, value|
        optional_config[key.to_s] = value
      end

      task = proxmox.openvz_post(ostemplate,
                          vmid,
                          optional_config)

      wait_status(proxmox, task)
    end

    desc "openvz_start", "Start an OpenVZ container"
    def openvz_start(vmid)
      config = load_proxmoxrc
      proxmox = authenticate(config)
      task = proxmox.openvz_start(vmid)
      wait_status(proxmox, task)
    end

    desc "openvz_shutdown", "Shutdown an OpenVZ container"
    def openvz_shutdown(vmid)
      config = load_proxmoxrc
      proxmox = authenticate(config)
      task = proxmox.openvz_shutdown(vmid)
      wait_status(proxmox, task)
    end

    desc "openvz_delete", "Delete an OpenVZ container"
    def openvz_delete(vmid)
      config = load_proxmoxrc
      proxmox = authenticate(config)
      task = proxmox.openvz_delete(vmid)
      wait_status(proxmox, task)
    end

    desc "openvz_status", "Show status of OpenVZ container"
    def openvz_status(vmid)
      config = load_proxmoxrc
      proxmox = authenticate(config)
      ap proxmox.openvz_status(vmid)
    end

    private

    def load_proxmoxrc
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

    def wait_status(server, task)
      puts task
      while server.task_status(task) == "running"
        print '.'
        sleep 1
      end
      puts server.task_status(task)
    end
  end
end
