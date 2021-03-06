require 'aws-sdk'

# If an AWS STS ROLE is defined, configure the AWS SDK to assume it
if ENV['AWS_STS_ROLE_ARN']
  Aws.config.update(
    credentials: Aws::AssumeRoleCredentials.new(
      role_arn: ENV['AWS_STS_ROLE_ARN'],
      role_session_name: "cog-#{ENV['COG_USER']}"
    )
  )
end

module CogCmd::Ecs::Helpers

  # Takes param in the form of '[ param_name, param_value]'. Returns nil if
  # param_value is nil.
  def param_or_nil(param)
    return nil if param[1] == nil
    param
  end

  def strip_prefix(str)
    str.sub(container_definition_root[:prefix], "")
  end

  def strip_json(str)
    str.sub(/\.json$/, "")
  end

  def container_definition_root
    parse_s3_url(ecs_container_def_url)
  end

  def container_definition_url(definition_name)
    return unless definition_name

    [ "https://#{container_definition_root['bucket']}.s3.amazonaws.com",
      "#{container_definition_root['prefix']}#{definition_name}.json" ].join('/')
  end

  private

  def ecs_container_def_url
    if def_url = ENV['ECS_CONTAINER_DEF_URL']
      append_slash(def_url)
    else
      raise Cog::Error, "Required environment variable 'ECS_CONTAINER_DEF_URL' missing"
    end
  end

  # So things will be consitant we add a slash to the end of cfn urls if one
  # doesn't already exist
  def append_slash(url)
    if url.end_with?("/")
      url
    else
      "#{url}/"
    end
  end

  def parse_s3_url(url)
    url.match(/((?<scheme>[^:]+):\/\/)?(?<bucket>[^\/]+)\/(?<prefix>.*)/)
  end

end
