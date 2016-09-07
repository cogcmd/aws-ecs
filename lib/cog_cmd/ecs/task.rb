require 'ecs/aggregate_command_with_usage'

class CogCmd::Ecs::Task < CogCmd::Ecs::AggregateCommandWithUsage

  SUBCOMMANDS = %w(register list families deregister show)

  USAGE = <<~END
  Usage: ecs:task <subcommand> [options]

  Subcommands:
    register <family> <def1 | def2 | ...>    Registers a new task
    deregister <family:revision>             Deregisters the specified task.
                                             Note: A family and revision must be specified
    list                                     Lists registered tasks and their revisions
    families                                 Lists task definition families
    show                                     Show details about a task definition

  Options:
    --help, -h   Show usage info
  END

end
