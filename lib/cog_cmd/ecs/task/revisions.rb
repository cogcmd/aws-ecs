require 'cog_cmd/ecs/helpers'

module CogCmd::Ecs::Task
  class Revisions < Cog::Command

    include CogCmd::Ecs::Helpers

    attr_reader :max_results, :status
    attr_reader :family_name

    def initialize
      # args
      @family_name = request.args[0]

      # options
      @max_results = request.options['limit']
      @status = request.options['inactive'] ? 'INACTIVE' : 'ACTIVE'
    end

    def run_command
      raise(Cog::Error, "You must specify a task family name.") unless family_name

      response.template = 'task_revision_list'
      response.content = list_definitions
    end

    private

    def list_definitions
      client = Aws::ECS::Client.new()

      params = {
        family_prefix: family_name,
        max_results: max_results,
        status: status,
      }.reject { |_key, value| value.nil? }

      client.list_task_definitions(params).task_definition_arns.map do |arn|
        _, task_def = arn.split(/:task-definition\//)
        { task_definition_revision: task_def,
          status: status }
      end
    end

  end
end

