require 'cog_cmd/ecs/helpers'

module CogCmd::Ecs::Task
  class Families < Cog::Command

    include CogCmd::Ecs::Helpers

    def run_command
      client = Aws::ECS::Client.new()

      ecs_params = Hash[
        [
          param_or_nil([ :family_prefix, request.options['family-prefix'] ]),
          param_or_nil([ :max_results, request.options['limit'] ]),
          param_or_nil([ :status, request.options['status'] ])
        ].compact
      ]

      results = client.list_task_definition_families(ecs_params).families.map do |family|
        { family: family }
      end

      response.template = 'task_family_list'
      response.content = results
    end

  end
end
