require 'json'
require_relative '../helpers'

class CogCmd::Ecs::Container::Define < Cog::SubCommand

  include CogCmd::Ecs::Helpers

  USAGE = <<-END.gsub(/^ {2}/, '')
  Usage: ecs:container define <name> <image> [options]

  Creates a new container definition.

  Options:
    --cpu <int>                                                     The number of cpu units reserved for the container.
    --memory <int>                                                  The hard limit (in MiB) of memory to present to the container.
    --memory-reservation <int>                                      The soft limit (in MiB) of memory to reserve for the container.
    --link <container name>                                         Link to another container. (Can be specified multiple times)
    --port-mapping <tcp|udp:container_port:host_port>               Port mapping for the container. (Can be specified multiple times)
    --essential <true|false>                                        If the essential parameter of a container is marked as true, and that container fails or stops for any reason, all other containers that are part of the task are stopped.
    --entrypoint <entrypoint>                                       An ENTRYPOINT allows you to configure a container that will run as an executable.
    --command <command>                                             The command that is passed to the container.
    --env <key=value>                                               The environment variables to pass to a container. (Can be specified multiple times)
    --mount-points <source_volume:container_path:read_only>         The mount points for data volumes in your container. If not specified 'read_only' defaults to 'false'.
    --volumes-from <source_container:read_only>                     Data volumes to mount from another container. If not specified 'read_only' defaults to 'false'.
    --hostname <hostname>                                           The hostname to use for the container.
    --user <user name>                                              The user name to use inside the container.
    --working-directory <dir>                                       The working directory in which to run commands inside the container.
    --disable-networking <true|false>                               When this parameter is true, networking is disabled within the container.  Defaults to 'false'.
    --privileged <true|false>                                       When this parameter is true, the container is given elevated privileges on the host container instance (similar to the root user). Defaults to 'false'.
    --read-only-root-filesystem <true|false>                        When this parameter is true, the container is given read-only access to its root file system. Defaults to 'false'.
    --dns-server <server>                                           A DNS server that is presented to the container. (Can be specified multiple times)
    --dns-search-domain <domain>                                    A DNS search domain that is presented to the container. (Can be specified multiple times)
    --extra-host <hostname:ip_address>                              Hostname and IP address mapping to append to the /etc/hosts file on the container. (Can be specified multiple times)
    --docker-security-option <option>                               A string to provide a custom label for SELinux and AppArmor multi-level security systems. (Can be specified multiple times)
    --docker-label <key=value>                                      A key/value map of labels to add to the container. (Can be specified multiple times)
    --ulimit <name:soft_limit:hard_limit>                           A ulimit to set in the container. (Can be specified multiple times)
    --log-configuration <log_driver:key1=value1:key2=value2:...>    The log configuration specification for the container.
  END

  def run_command
    unless name = request.args[0]
      raise CogCmd::Ecs::ArgumentError, "A container definition name must be specified."
    end

    unless image = request.args[1]
      raise CogCmd::Ecs::ArgumentError, "A Docker image must be specified."
    end

    def_params = {
      name: name,
      image: image
    }.merge(process_options(request.options))

    container_def = Aws::ECS::Types::ContainerDefinition.new(def_params)
    client = Aws::S3::Client.new()

    bucket = container_definition_root[:bucket]
    key = "#{container_definition_root[:prefix]}#{container_def.name}.json"
    body = JSON.pretty_generate(container_def.to_h)

    client.put_object(bucket: bucket, key: key, body: body)
    resp = client.get_object(bucket: bucket, key: key)

    JSON.parse(resp.body.read)
  end

  private

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
    strings = %w(hostname user working_directory)
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
