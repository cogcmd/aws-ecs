require 'json'
require_relative '../helpers'
require_relative 'helpers'

class CogCmd::Ecs::Container::Define < Cog::SubCommand

  include CogCmd::Ecs::Helpers
  include CogCmd::Ecs::Container::Helpers


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

end
