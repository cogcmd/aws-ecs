require 'json'
require 'ecs/helpers'
require 'ecs/container/helpers'

module CogCmd::Ecs::Container
  class Define < Cog::Command

    include CogCmd::Ecs::Helpers
    include CogCmd::Ecs::Container::Helpers

    def run_command
      unless name = request.args[0]
        raise Cog::Error, "A container definition name must be specified."
      end

      unless image = request.args[1]
        raise Cog::Error, "A Docker image must be specified."
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

      response.template = 'definition_show'
      response.content = JSON.parse(resp.body.read)
    end

  end
end
