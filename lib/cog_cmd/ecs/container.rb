require_relative 'aggregate_command_with_usage'

class CogCmd::Ecs::Container < CogCmd::Ecs::AggregateCommandWithUsage

  SUBCOMMANDS = %w(list show define)

  USAGE = <<~END
  Usage: ecs:container <subcommand> [options]

  Manage ECS Container Definitions.

  Subcommands:
    list                    Lists available container definitions.
    show <definition name>  Shows the json body of a specific container definition.
    define <name> <image>   Creates a new container definition.

  Options:
    --help, -h        Show usage
  END

end
