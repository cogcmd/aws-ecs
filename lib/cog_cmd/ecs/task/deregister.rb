require 'ecs/helpers'

class CogCmd::Ecs::Task::Deregister < Cog::SubCommand

  include CogCmd::Ecs::Helpers

  USAGE = <<~END
  Usage: ecs:task deregister <family:revision>

  Deregisters a task
  Note: Both family and revision must be specified
  END

  def run_command
    unless task = request.args[0]
      raise CogCmd::Ecs::ArgumentError, "You must specify a family and revision 'family:revision'"
    end

    unless task.split(':')[1]
      raise CogCmd::Ecs::ArgumentError, "You must specify a family and revision 'family:revision'"
    end

    client = Aws::ECS::Client.new()

    client.deregister_task_definition(task_definition: task).to_h
  end

end
