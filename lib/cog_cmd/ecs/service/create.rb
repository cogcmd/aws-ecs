require 'cog_cmd/ecs/helpers'
require 'cog_cmd/ecs/service/helpers'
require 'securerandom'

module CogCmd::Ecs::Service
  class Create < Cog::Command

    include CogCmd::Ecs::Helpers
    include CogCmd::Ecs::Service::Helpers

    DEFAULT_DESIRED_COUNT = 1

    attr_reader :service_name, :task_definition, :desired_count
    attr_reader :cluster_name, :role

    def initialize
      # args
      @service_name = request.args[0]
      @task_definition = request.args[1]
      @desired_count = request.args[2] || DEFAULT_DESIRED_COUNT

      # options
      @cluster_name = request.options['cluster']
      @deployment_config = request.options['deployment-config']
      @load_balancer = request.options['load-balancer']
      @role = request.options['role']
    end

    def run_command
      raise(Cog::Error, "A service name must be specified.") unless service_name
      raise(Cog::Error, "A task definition must be specified.") unless task_definition

      response.template = 'service_show'
      response.content = create_service
    end

    private

    def create_service
      client = Aws::ECS::Client.new()

      params = {
        service_name: service_name,
        task_definition: task_definition,
        desired_count: desired_count,
        client_token: generate_token
      }
      params['cluster'] = cluster_name                       if cluster_name
      params['deployment_configuration'] = deployment_config if deployment_config
      params['load_balancers'] = [load_balancer]             if load_balancer
      params['role'] = role                                  if role

      client.create_service(params).service.to_h
    end

    def generate_token
      SecureRandom.uuid
    end

    def load_balancer
      return unless @load_balancer

      # load balancers are specified one of two ways depending on the type.
      # Elastic load balancing classic is specified with the container name,
      # container port and load balancer name; 'container:port:lb_name'.
      # Elastic load balancing application load balancers are specified with
      # the container name, container port and the load balancer target group
      # arn; 'container:port:arn'. Since arns contain colons, ':', when we
      # split if the last element contains a colon it's the arn and not the name.
      name, port, name_or_arn = @load_balancer.strip.split(':', 3)
      name_or_arn_key = name_or_arn.include?(':') ? :target_group_arn : :load_balancer_name

      { :container_name => name,
        :container_port => port,
        name_or_arn_key => name_or_arn }
    end

  end
end
