require 'ecs/helpers'

class CogCmd::Ecs::Container::List < Cog::SubCommand

  include CogCmd::Ecs::Helpers

  USAGE = <<~END
  Usage: ecs:container list

  Lists ECS container definitions.
  END

  def run_command
    client = Aws::S3::Client.new()

    client.list_objects_v2(bucket: container_definition_root[:bucket], prefix: container_definition_root[:prefix])
    .contents
    .find_all { |obj|
      obj.key.end_with?('.json')
    }
    .map { |obj|
      { name: strip_json(strip_prefix(obj.key)),
        last_modified: obj.last_modified }
    }
  end

end
