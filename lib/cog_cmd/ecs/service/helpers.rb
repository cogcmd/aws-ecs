module CogCmd::Ecs::Service
  module Helpers
    def deployment_config
      return unless @deployment_config
      config = @deployment_config.strip.split(':')

      { minimum_healthy_percent: config[0],
        maximum_percent: config[1] }
    end
  end
end
