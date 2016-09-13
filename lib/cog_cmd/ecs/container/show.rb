require 'json'
require 'cog_cmd/ecs/helpers'

module CogCmd::Ecs::Container
  class Show < Cog::Command

    include CogCmd::Ecs::Helpers

    def run_command
      raise(Cog::Error, "You must specify a definition name.") unless def_name

      response.template = 'definition_show'
      response.content = get_container_definition
    end

    private

    def def_name
      request.args[0]
    end

    def get_container_definition
      client = Aws::S3::Client.new()

      key = "#{container_definition_root[:prefix]}#{def_name}.json"
      JSON.parse(client.get_object(bucket: container_definition_root[:bucket], key: key).body.read)
    end

  end
end
