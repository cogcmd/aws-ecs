require 'cog_cmd/ecs/helpers'

module CogCmd::Ecs::Service
  class Show < Cog::Command

    include CogCmd::Ecs::Helpers

    attr_reader :service_names
    attr_reader :cluster_name

    def initialize
      # args
      @service_names = request.args

      # options
      @cluster_name = request.options['cluster']
    end

    def run_command
      raise(Cog::Error, "At least one service name must be specified.") unless service_names.length > 0

      response.template = 'service_show'
      response.content = show_services
    end

    private

    def show_services
      client = Aws::ECS::Client.new()

      params = {
        services: service_names
      }
      params[:cluster] = cluster_name if cluster_name

      client.describe_services(params).to_h
    end

  end
end
