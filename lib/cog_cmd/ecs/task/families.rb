require 'cog_cmd/ecs/helpers'

module CogCmd::Ecs::Task
  class Families < Cog::Command

    include CogCmd::Ecs::Helpers

    attr_reader :max_results, :status
    attr_reader :family_prefix

    def initialize
      # args
      @family_prefix = request.args[0]

      # options
      @max_results = request.options['limit']
      @status = request.options['inactive'] ? 'INACTIVE' : 'ACTIVE'
    end

    def run_command
      response.template = 'task_family_list'
      response.content = list_definitions
    end

    private

    def list_definitions
      client = Aws::ECS::Client.new()

      params = {
        family_prefix: family_prefix,
        max_results: max_results,
        status: status,
      }.reject { |_key, value| value.nil? }

      client.list_task_definition_families(params).families.map do |family|
        { task_definition_family: family,
          status: status }
      end
    end

  end
end

