require 'json'
require_relative '../exceptions'
require_relative '../helpers'

class CogCmd::Ecs::Container::Show < Cog::SubCommand

  include CogCmd::Ecs::Helpers

  USAGE = <<~END
  Usage: ecs:container show <definition name>

  Shows the json body of a specific container definition.
  END

  def run_command
    unless def_name = request.args[0]
      msg = "You must specify a definition name."
      raise CogCmd::Ecs::ArgumentError, msg
    end

    client = Aws::S3::Client.new()

    key = "#{container_definition_root[:prefix]}#{def_name}.json"
    resp = client.get_object(bucket: container_definition_root[:bucket], key: key)

    JSON.parse(resp.body.read)
  end

end
