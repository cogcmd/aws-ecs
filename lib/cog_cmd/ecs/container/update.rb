require 'json'
require 'cog_cmd/ecs/helpers'
require 'cog_cmd/ecs/container/helpers'

module CogCmd::Ecs::Container
  class Update < Cog::Command

    include CogCmd::Ecs::Helpers
    include CogCmd::Ecs::Container::Helpers

    def run_command
      raise(Cog::Error, "A container definition name must be specified.") unless def_name

      response.template = 'definition_show'
      response.content = update_container_definition
    end

    private

    def def_name
      request.args[0]
    end

    def update_container_definition
      client = Aws::S3::Client.new()

      bucket = container_definition_root[:bucket]
      key = "#{container_definition_root[:prefix]}#{def_name}.json"
      resp = client.get_object(bucket: bucket, key: key)

      def_params = JSON.parse(resp.body.read).merge(process_options(request.options))

      container_def = Aws::ECS::Types::ContainerDefinition.new(def_params)
      body = JSON.pretty_generate(container_def.to_h)

      client.put_object(bucket: bucket, key: key, body: body)
      JSON.parse(client.get_object(bucket: container_definition_root[:bucket], key: key).body.read)
    end

  end
end
