require 'ecs/aggregate_command_with_usage'

class CogCmd::Ecs::Task < CogCmd::Ecs::AggregateCommandWithUsage

  SUBCOMMANDS = %w(register list families)

  USAGE = <<~END
  Usage: ecs:task <subcommand> [options]

  Subcommands:
    register <family> <def1 | def2 | ...>    Registers a new task
    list                                     Lists registered tasks and their revisions
    families                                 Lists task definition families

  Options:
    --help, -h   Show usage info
  END

end
