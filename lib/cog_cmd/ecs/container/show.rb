class CogCmd::Ecs::Container::Show < Cog::SubCommand

  USAGE = <<~END
  Usage: ecs:container show <definition name>

  Shows the json body of a specific container definition.
  END

  def run_command
    {command: "show"}
  end

end
