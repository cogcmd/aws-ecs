require 'json'
require 'cog_cmd/ecs/helpers'
require 'cog_cmd/ecs/container/helpers'

module CogCmd::Ecs::Container
  class Define < Cog::Command

    include CogCmd::Ecs::Helpers
    include CogCmd::Ecs::Container::Helpers

    def run_command
      raise(Cog::Error, "A container definition name must be specified.") unless def_name
      raise(Cog::Error, "A Docker image must be specified.") unless image_name

      response.template = 'definition_show'
      response.content = put_container_def
    end

    private

    def def_name
      request.args[0]
    end

    def image_name
      request.args[1]
    end

    def container_def
      return @container_def if @container_def

      def_params = {
        name: def_name,
        image: image_name
      }.merge(process_options(request.options))

      @container_def = Aws::ECS::Types::ContainerDefinition.new(def_params)
    end

    def put_container_def
      client = Aws::S3::Client.new()

      bucket = container_definition_root[:bucket]
      key = "#{container_definition_root[:prefix]}#{container_def.name}.json"
      body = JSON.pretty_generate(container_def.to_h)

      client.put_object(bucket: bucket, key: key, body: body)
      JSON.parse(client.get_object(bucket: bucket, key: key).body.read)
    end

  end

end
