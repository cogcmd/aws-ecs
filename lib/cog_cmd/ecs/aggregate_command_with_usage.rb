require 'ecs/helpers'

class CogCmd::Ecs::AggregateCommandWithUsage < Cog::AggregateCommand

  include CogCmd::Ecs::Helpers

  def run_command
    # If the user requests help for a subcommand we return it, otherwise
    # we just call super, which invokes the subcommand.
    if request.options['help']
      response['body'] = usage(subcommand.class::USAGE)
    else
      super
    end
  rescue CogCmd::Ecs::ArgumentError => msg
    response['body'] = usage(subcommand.class::USAGE, error(msg))
  end

  # We override require_subcommand! to insert a check for the help flag and
  # return the proper usage info
  def require_subcommand!(subcommand, subcommands)
    if request.options['help']
      super(subcommand, subcommands, Cog::Stop)
    else
      super(subcommand, subcommands)
    end
  end

  # If no subcommand is passed we error, but only if the help flag isn't
  # passed. Regardless we need to prepend the usage info.
  def missing_subcommand_msg(subcommands)
    if request.options['help']
      usage(self.class::USAGE)
    else
      usage(self.class::USAGE, error(super(subcommands)))
    end
  end

  # Prepends usage info to the unknown subcommand error message
  def unknown_subcommand_msg(subcommand, subcommands)
    usage(self.class::USAGE, error(super(subcommand, subcommands)))
  end

end
