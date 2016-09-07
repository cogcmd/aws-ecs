require 'ecs/helpers'

class CogCmd::Ecs::Task::Show < Cog::SubCommand

  include CogCmd::Ecs::Helpers

  USAGE = <<~END
  Usage: ecs:task show <family | family:revision>

  Shows the task definition.
  Note: You can supply the family and revision or just the family. If you
  supply just the family the latest active revision in the family will be
  assumed.

  END

  def run_command
    unless task = request.args[0]
      raise CogCmd::Ecs::ArgumentError, 'A family or family and revision must be specified'
    end

    client = Aws::ECS::Client.new()

    client.describe_task_definition(task_definition: task).to_h
  end
end
