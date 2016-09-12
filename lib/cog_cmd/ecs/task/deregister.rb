require 'cog_cmd/ecs/helpers'

module CogCmd::Ecs::Task
  class Deregister < Cog::Command

    include CogCmd::Ecs::Helpers

    def run_command
      unless task = request.args[0]
        raise CogCmd::Ecs::ArgumentError, "You must specify a family and revision 'family:revision'"
      end

      unless task.split(':')[1]
        raise CogCmd::Ecs::ArgumentError, "You must specify a family and revision 'family:revision'"
      end

      client = Aws::ECS::Client.new()

      results = client.deregister_task_definition(task_definition: task)

      response.template = 'task_show'
      response.content = results.task_definition.to_h
    end

  end
end
