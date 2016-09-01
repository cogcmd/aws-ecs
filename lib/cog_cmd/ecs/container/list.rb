class CogCmd::Ecs::Container::List < Cog::SubCommand

  USAGE = <<~END
  Usage: ecs:container list

  Lists ECS container definitions.
  END

  def run_command
    {command: "list"}
  end

end
