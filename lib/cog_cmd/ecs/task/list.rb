require 'ecs/helpers'

module CogCmd::Ecs::Task
  class List < Cog::Command

    include CogCmd::Ecs::Helpers

    def run_command
      client = Aws::ECS::Client.new()

      ecs_params = Hash[
        [
          # Little hack to get around all subcommands having to share options.
          # list_task_definition only takes the full family name to filter on instead
          # of the family_prefix. But it still refers to it as the family_prefix.
          # To hopefully prevent some confusion we renamed it family in the options,
          # but we accept both family and family-prefix.
          param_or_nil([ :family_prefix, request.options['family-prefix'] || request.options['family'] ]),
          param_or_nil([ :max_results, request.options['limit'] ]),
          param_or_nil([ :status, request.options['status'] ]),
          param_or_nil([ :sort, request.options['sort'] ])
        ].compact
      ]

      definition_arns = fetch_task_definitions(client, ecs_params)
      response.content = process_definition_arns(definition_arns)

    end

    private

    def fetch_task_definitions(client, params, next_token = nil, defs = [])
      return defs if next_token == :end

      params['next_token'] = next_token if next_token

      resp = client.list_task_definitions(params)
      next_token = resp.next_token || :end
      definitions = defs.push(resp.task_definition_arns).flatten
      fetch_task_definitions(client, params, next_token, definitions)
    end

    def process_definition_arns(arns)
      arns.reduce(Hash.new) do |acc, arn|
        family_revision = arn.split('/')[1]
        family = family_revision.split(':')[0]
        acc[family] = acc[family] || {family: family, revisions: []}
        acc[family][:revisions].push(family_revision)
        acc
      end.values
    end

  end
end
