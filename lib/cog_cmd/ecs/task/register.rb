require 'ecs/helpers'

class CogCmd::Ecs::Task::Register < Cog::SubCommand

  include CogCmd::Ecs::Helpers

  USAGE = <<~END
  Usage: ecs:task register <family> <def1 | def2 | ...>

  Registers a new task
  Note: Definitions are container definition names as listed by ecs:container list

  Options:
    --role, -r <role>                     IAM Role for containers in this task to assume
    --network-mode <bridge | host | none> Docker networking mode
    --volume, -v <name:path>              Volume definition defined as 'name:path' (Can be specified multiple times)
  END

  def run_command
    args = request.args

    unless family = args.shift
      raise CogCmd::Ecs::ArgumentError, "A family must be specified."
    end

    unless args.length > 0
      raise CogCmd::Ecs::ArgumentError, "At least one container definition must be specified."
    end

    client = Aws::ECS::Client.new()

    defs = fetch_container_defs!(args)

    ecs_params = Hash[
      [
        [ :family, family ],
        [ :container_definitions, defs ],
        param_or_nil([ :task_role_arn, request.options['role'] ]),
        param_or_nil([ :network_mode, request.options['network-mode'] ]),
        param_or_nil([ :volumes, process_volumes(request.options['volume']) ])
      ].compact
    ]

    client.register_task_definition(ecs_params).to_h
  end

  private

  def process_volumes(volumes)
    return unless volumes

    volumes.map do |v|
      volume = v.strip.split(':')
      { name: volume[0],
        host: { source_path: volume[1] } }
    end

  end

  def fetch_container_defs!(def_names)
    client = Aws::S3::Client.new()

    def_names.map do |def_name|
      begin
        key = "#{container_definition_root[:prefix]}#{def_name}.json"
        resp = client.get_object(bucket: container_definition_root[:bucket], key: key)

        JSON.parse(resp.body.read)
      rescue Aws::S3::Errors::NoSuchKey => _msg
        raise Cog::Error, "A container definition named '#{def_name}' could not be found."
      end
    end

  end

end
