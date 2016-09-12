require 'cog_cmd/ecs/helpers'

module CogCmd::Ecs::Container
  class Delete < Cog::Command

    include CogCmd::Ecs::Helpers

    def run_command
      unless def_name = request.args[0]
        raise Cog::Error, "You must specify a definition name."
      end

      client = Aws::S3::Client.new()

      key = "#{container_definition_root[:prefix]}#{def_name}.json"
      client.delete_object(bucket: container_definition_root[:bucket], key: key)

      response.template = 'definition_delete'
      response.content = { status: "deleted",
                           name: def_name }
    end

  end
end
