require 'cog_cmd/ecs/helpers'

module CogCmd::Ecs::Container
  class List < Cog::Command

    include CogCmd::Ecs::Helpers

    def run_command
      response.template = 'definition_table'
      response.content = list_objects.reduce([]) do |acc, obj|
        acc.push(process_obj(obj)) if json_key?(obj)
        acc
      end
    end

    private

    def list_objects
      client = Aws::S3::Client.new()

      params = {
        bucket: container_definition_root[:bucket],
        prefix: container_definition_root[:prefix]
      }

      client.list_objects_v2(params).contents
    end

    def json_key?(obj)
      obj.key.end_with?('.json')
    end

    def process_obj(obj)
      { name: strip_json(strip_prefix(obj.key)),
        last_modified: obj.last_modified }
    end

  end
end
