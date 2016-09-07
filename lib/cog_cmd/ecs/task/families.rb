require 'ecs/helpers'

class CogCmd::Ecs::Task::Families < Cog::SubCommand

  include CogCmd::Ecs::Helpers

  USAGE = <<~END
  Usage: ecs:task families [options]

  Lists task definition families

  Options:
    --family-prefix, -f <family name>   The name of the family with which to filter the results
    --limit, -l <num>                   Limit the number of results returned
    --status <ACTIVE | INACTIVE>        Filter by the desired status of the task
  END

  def run_command
    client = Aws::ECS::Client.new()

    ecs_params = Hash[
      [
        param_or_nil([ :family_prefix, request.options['family-prefix'] ]),
        param_or_nil([ :max_results, request.options['limit'] ]),
        param_or_nil([ :status, request.options['status'] ])
      ].compact
    ]

    client.list_task_definition_families(ecs_params).families.map do |family|
      { family: family }
    end
  end
end
