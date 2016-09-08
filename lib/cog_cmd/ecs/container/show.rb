require 'json'
require 'ecs/helpers'

module CogCmd::Ecs::Container
  class Show < Cog::Command

    include CogCmd::Ecs::Helpers

    def run_command
      unless def_name = request.args[0]
        raise Cog::Error, "You must specify a definition name."
      end

      client = Aws::S3::Client.new()

      key = "#{container_definition_root[:prefix]}#{def_name}.json"
      resp = client.get_object(bucket: container_definition_root[:bucket], key: key)

      response.content = JSON.parse(resp.body.read)
    end

  end
end
