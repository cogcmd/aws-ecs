require 'ecs/helpers'

module CogCmd::Ecs::Task
  class Register < Cog::Command

    include CogCmd::Ecs::Helpers

    def run_command
      args = request.args

      unless family = args.shift
        raise CogCmd::Ecs::ArgumentError, "A family must be specified."
      end

      unless args.length > 0 || request.options['use-previous-revision']
        raise CogCmd::Ecs::ArgumentError, "At least one container definition must be specified."
      end

      client = Aws::ECS::Client.new()

      defs = fetch_container_defs!(args)

      ecs_params = Hash[
        [
          [ :family, family ],
          [ :container_definitions, defs ],
          param_or_nil([ :task_role_arn, request.options['role'] ]),
          param_or_nil([ :network_mode, request.options['network-mode'] ]),
          param_or_nil([ :volumes, process_volumes(request.options['volume']) ])
        ].compact
      ]

      if request.options['use-previous-revision']
        ecs_params = merge_previous_revision(ecs_params, args)
      end

      results = client.register_task_definition(ecs_params)

      response.content = results.to_h
    end

    private

    def fetch_container_defs!(def_names = [])
      client = Aws::S3::Client.new()

      def_names.map do |def_name|
        begin
          key = "#{container_definition_root[:prefix]}#{def_name}.json"
          resp = client.get_object(bucket: container_definition_root[:bucket], key: key)

          Aws::ECS::Types::ContainerDefinition.new(JSON.parse(resp.body.read))
        rescue Aws::S3::Errors::NoSuchKey => _msg
          raise Cog::Error, "A container definition named '#{def_name}' could not be found."
        end
      end

    end

    def merge_previous_revision(params, def_names)
      client = Aws::ECS::Client.new()

      task_def = client.describe_task_definition(task_definition: params[:family]).task_definition
      params[:task_role_arn] = task_def.task_role_arn if task_def.task_role_arn
      params[:network_mode] = task_def.network_mode if task_def.network_mode

      if request.options['volume']
        if request.options['replace-volumes']
          params[:volumes] = process_volumes(request.options['volume'])
        else
          params[:volumes] = merge_volumes(task_def.volumes, request.options['volume'])
        end
      end

      if request.options['replace-definitions']
        params[:container_definitions] = fetch_container_defs!(def_names)
      elsif def_names.length > 0
        params[:container_definitions] = merge_container_defs(task_def.container_definitions, def_names)
      else
        params[:container_definitions] = task_def.container_definitions
      end

      params
    end

    # If a new container def with the same name as the old def is present, the new
    # def will replace the old one. Otherwise new defs are appended to the end.
    def merge_container_defs(original_defs, new_defs)
      new_defs = fetch_container_defs!(new_defs)

      merged_defs = original_defs.map do |orig_def|
        container_def = orig_def

        new_defs.each do |new_def|
          if new_def.name == orig_def.name
            container_def = new_defs.delete(new_def)
          end
        end

        container_def
      end

      merged_defs.push(new_defs).flatten
    end

    def process_volumes(volumes)
      return unless volumes

      volumes.map do |v|
        volume = v.strip.split(':')
        { name: volume[0],
          host: { source_path: volume[1] } }
      end
    end

    # If a new volume with the same name as the old volume is present, the new
    # volume value will replace the old one. Otherwise the volume is appended
    # to the list of volumes.
    def merge_volumes(original_volumes, new_volumes)
      new_volumes = process_volumes(new_volumes)

      merged_volumes = original_volumes.map do |orig_vol|
        volume = orig_vol

        new_volumes.each do |new_vol|
          if new_vol[:name] == orig_vol[:name]
            volume = new_volumes.delete(new_vol)
          end
        end

        volume
      end

      merged_volumes.push(new_volumes).flatten
    end

  end
end
