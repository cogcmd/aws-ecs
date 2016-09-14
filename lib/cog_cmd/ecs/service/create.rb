require 'cog_cmd/ecs/helpers'
require 'securerandom'

module CogCmd::Ecs::Service
  class Create < Cog::Command

    include CogCmd::Ecs::Helpers

    attr_reader :service_name, :task_definition, :desired_count
    attr_reader :cluster_name, :role

    def initialize
      @service_name = request.args[0]
      @task_definition = request.args[1]
      @desired_count = request.args[2] || 1

      @cluster_name = request.options['cluster']
      @deployment_config = request.options['deployment-config']
      @load_balancer = request.options['load-balancer']
      @role = request.options['role']
    end

    def run_command
      raise(Cog::Error, "A service name must be specified.") unless service_name
      raise(Cog::Error, "A task definition must be specified.") unless task_definition

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

      client.create_service(params).to_h
    end

    def generate_token
      SecureRandom.uuid
    end

    def deployment_config
      return unless @deployment_config
      config = @deployment_config.strip.split(':')

      { minimum_healthy_percent: config[0],
        maximum_percent: config[1] }
    end

    def load_balancer
      return unless @load_balancer
      lb = @load_balancer.strip.split(':')

      # load balancers are specified one of two ways depending on the type.
      # Elastic load balancing classic is specified with the container name,
      # container port and load balancer name; 'container:port:lb_name'.
      # Elastic load balancing application load balancers are specified with
      # the container name, container port and the load balancer target group
      # arn; 'container:port:arn'. Since arns contain colons, ':', when we
      # split and the length is 3 then we should be dealing with a classic
      # load balancer and we set values accordingly. If the length is greater
      # than three we assume it's an application load balancer and join the last
      # elements to reform the target group arn.
      if lb.length == 3
        { container_name: lb[0],
          container_port: lb[1],
          load_balancer_name: lb[2] }
      else
        { container_name: lb.shift,
          container_port: lb.shift,
          target_group_arn: lb.join(':') }
      end
    end

  end
end
