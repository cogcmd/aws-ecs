require 'cog_cmd/ecs/helpers'

module CogCmd::Ecs::Task
  class List < Cog::Command

    include CogCmd::Ecs::Helpers

    attr_reader :family_prefix, :max_results, :status
    attr_reader :task_definition

    def initialize
      # args
      @task_definition = request.args[0]

      # options
      @family_prefix = request.options['family-prefix']
      @max_results = request.options['limit']
      @status = request.options['inactive'] ? 'INACTIVE' : 'ACTIVE'
    end

    def run_command
      response.template = 'task_list'
      response.content = list_definitions
    end

    private

    def list_definitions
      client = Aws::ECS::Client.new()

      params = {
        family_prefix: task_definition || family_prefix,
        max_results: max_results,
        status: status,
      }.reject { |_key, value| value.nil? }

      # If the user doesn't pass a task definition name we list task definition
      # families. If they do we list task definition revisions.
      if task_definition.nil?
        list_task_definition_families(client, params)
      else
        list_task_definitions(client, params)
      end
    end

    def list_task_definition_families(client, params)
      client.list_task_definition_families(params).families.map do |family|
        { task_definition_family: family,
          status: status }
      end
    end

    def list_task_definitions(client, params)
      client.list_task_definitions(params).task_definition_arns.map do |arn|
        _, task_def = arn.split(/:task-definition\//)
        { task_definition_revision: task_def,
          status: status }
      end
    end

  end
end
