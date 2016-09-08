require 'ecs/helpers'

module CogCmd::Ecs::Container
  class List < Cog::Command

    include CogCmd::Ecs::Helpers

    def run_command
      client = Aws::S3::Client.new()

      resp = client.list_objects_v2(bucket: container_definition_root[:bucket], prefix: container_definition_root[:prefix])
      .contents
      .find_all { |obj|
        obj.key.end_with?('.json')
      }
      .map { |obj|
        { name: strip_json(strip_prefix(obj.key)),
          last_modified: obj.last_modified }
      }

      response.content = resp
    end

  end
end
