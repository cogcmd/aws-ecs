require 'cog_cmd/ecs/helpers'

module CogCmd::Ecs::Container
  class Delete < Cog::Command

    include CogCmd::Ecs::Helpers

    def run_command
      raise(Cog::Error, "You must specify a definition name.") unless def_name

      delete_definition

      response.template = 'definition_delete'
      response.content = { status: "deleted",
                           name: def_name }
    end

    private

    def def_name
      request.args[0]
    end

    def delete_definition
      client = Aws::S3::Client.new()

      key = "#{container_definition_root[:prefix]}#{def_name}.json"
      client.delete_object(bucket: container_definition_root[:bucket], key: key)
    end

  end
end
