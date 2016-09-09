require 'ecs/helpers'

module CogCmd::Ecs::Task
  class Show < Cog::Command

    include CogCmd::Ecs::Helpers

    def run_command
      unless task = request.args[0]
        raise CogCmd::Ecs::ArgumentError, 'A family or family and revision must be specified'
      end

      client = Aws::ECS::Client.new()

      results = client.describe_task_definition(task_definition: task)

      response.content = results.to_h
    end

  end
end
