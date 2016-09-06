require 'ecs/aggregate_command_with_usage'

class CogCmd::Ecs::Container < CogCmd::Ecs::AggregateCommandWithUsage

  SUBCOMMANDS = %w(list show define update delete)

  USAGE = <<~END
  Usage: ecs:container <subcommand> [options]

  Manage ECS Container Definitions.

  Subcommands:
    list                   Lists available container definitions.
    show <name>            Shows the json body of a specific container definition.
    define <name> <image>  Creates a new container definition.
    delete <name>          Deletes a container definition.
    update <name>          Updates a container definition.

  Options:
    --help, -h        Show usage
  END

end
