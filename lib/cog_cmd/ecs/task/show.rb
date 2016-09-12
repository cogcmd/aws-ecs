require 'cog_cmd/ecs/helpers'

module CogCmd::Ecs::Task
  class Show < Cog::Command

    include CogCmd::Ecs::Helpers

    def run_command
      unless task = request.args[0]
        raise CogCmd::Ecs::ArgumentError, 'A family or family and revision must be specified'
      end

      client = Aws::ECS::Client.new()

      result = client.describe_task_definition(task_definition: task)

      response.template = 'task_show'
      response.content = result.task_definition.to_h
    end

  end
end
