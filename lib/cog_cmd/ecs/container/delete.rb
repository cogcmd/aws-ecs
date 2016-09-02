require 'ecs/helpers'

class CogCmd::Ecs::Container::Delete < Cog::SubCommand

  include CogCmd::Ecs::Helpers

  USAGE = <<~END
  Usage: ecs:container delete <name>

  Deletes the specified container definition
  END

  def run_command
    unless def_name = request.args[0]
      msg = "You must specify a definition name."
      raise CogCmd::Ecs::ArgumentsError, msg
    end

    client = Aws::S3::Client.new()

    key = "#{container_definition_root[:prefix]}#{def_name}.json"
    client.delete_object(bucket: container_definition_root[:bucket], key: key)

    { status: "deleted",
      name: def_name }
  end

end
