require 'ecs/helpers'

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

      response.content = results.to_h
    end

  end
end
