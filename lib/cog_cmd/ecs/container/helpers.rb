module CogCmd::Ecs::Container
  module Helpers

    def process_options(options)
      processed_options = Hash.new()

      options.each_pair do |key, value|
        key = key.gsub(/-/, '_')

        case type(key)
        when :int
          new_key = key
          new_value = value.to_i
        when :bool
          new_key = key
          new_value = value == 'true' ? true : false
        when :list
          new_key = "#{key}s"
          new_value = value
        when :special
          special = self.send("process_#{key}".to_sym, value)
          new_key = special[:key]
          new_value = special[:value]
        else
          new_key = key
          new_value = value
        end

        processed_options[new_key] = new_value
      end

      processed_options
    end

    def type(key)
      ints = %w(cpu memory memory_reservation)
      strings = %w(hostname user working_directory image)
      bools = %(disable_networking privileged essential readonly_root_filesystem)
      lists = %w(link dns_server dns_search_domain docker_security_option)
      specials = %w(entry_point command port_mapping env mount_point volume_from extra_host docker_label ulimit log_configuration)

      if ints.include?(key)
        :int
      elsif strings.include?(key)
        :string
      elsif bools.include?(key)
        :bool
      elsif lists.include?(key)
        :list
      elsif specials.include?(key)
        :special
      end
    end

    def process_entry_point(entry_point)
      { key: 'entry_point',
        value: entry_point.split(' ') }
    end

    def process_command(command)
      { key: 'command',
        value: command.split(' ') }
    end

    def process_port_mapping(mappings)
      new_mappings = mappings.map do |mapping|
        m = mapping.split(':')
        { protocol: m[0].strip,
          container_port: m[1].strip.to_i,
          host_port: m[2].strip.to_i }
      end

      { key: 'port_mappings',
        value: new_mappings }
    end

    def process_env(envs)
      new_envs = envs.map do |var|
        env = var.split("=")
        { name: env[0].strip,
          value: env[1].strip }
      end

      { key: 'environment',
        value: new_envs }
    end

    def process_mount_point(points)
      new_points = points.map do |point|
        p = point.split(':')
        read_only = p[2] == 'true' ? true : false

        { source_volume: p[0].strip,
          container_path: p[1].strip,
          read_only: read_only }
      end

      { key: 'mount_points',
        value: new_points }
    end

    def process_volume_from(volumes)
      new_volumes = volumes.map do |volume|
        v = volume.split(':')
        read_only = v[1] == 'true' ? true : false

        { source_container: v[0].strip,
          read_only: read_only }
      end

      { key: 'volumes_from',
        value: new_volumes }
    end

    def process_extra_host(hosts)
      new_hosts = hosts.map do |host|
        h = host.split(':')

        { hostname: h[0].strip,
          ip_address: h[1].strip }
      end

      { key: 'extra_hosts',
        value: new_hosts }
    end

    def process_docker_label(labels)
      new_labels = Hash.new()

      labels.each do |label|
        l = label.split('=')
        new_labels[l[0].strip] = l[1].strip
      end

      { key: 'docker_labels',
        value: new_labels }
    end

    def process_ulimit(ulimits)
      new_ulimits = ulimits.map do |ulimit|
        u = ulimit.split(':')

        { name: u[0].strip,
          soft_limit: u[1].strip.to_i,
          hard_limit: u[2].strip.to_i }
      end

      { key: 'ulimits',
        value: new_ulimits }
    end

    def process_log_configuration(config)
      c = config.split(':')
      driver = c.shift
      options = Hash.new()

      c.each do |opt|
        o = opt.split('=')

        options[o[0].strip] = o[1].strip
      end

      { key: 'log_configuration',
        value:
        { log_driver: driver,
          options: options } }
    end

  end
end
