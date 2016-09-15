require 'cog_cmd/ecs/helpers'

module CogCmd::Ecs::Service
  class List < Cog::Command

    include CogCmd::Ecs::Helpers

    attr_reader :cluster_name, :limit

    def initialize
      @cluster_name = request.args[0]
      @limit = request.options['limit']
    end

    def run_command
      response.template = 'service_table'
      response.content = list_services
    end

    private

    def list_services
      client = Aws::ECS::Client.new()

      params = {}
      params[:cluster] = cluster_name if cluster_name
      params[:max_results] = limit if limit

      # the api returns a list of service arns in the form of
      # 'arn:aws:ecs:us-east-1:934873600520:service/buildkite-cogctl-SYCZDEARFMY'
      # We strip grab the name from the end of the string and return that along
      # with the original arn in a list of hashes.
      client.list_services(params).service_arns.map do |service|
        { name: service.split(/service\//)[1],
          arn: service }
      end
    end
  end
end
