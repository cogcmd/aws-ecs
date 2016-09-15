~each var=$results as=task~
~attachment title=$task.family color="blue"~
_Revision:_ ~$task.revision~
_Status:_ ~$task.status~
_ARN:_ ~$task.task_definition_arn~
~end~
~if cond=$task.volumes not_empty?~
~attachment title="Volumes" color="mediumblue"~
~json var=$task.volumes~
~end~
~end~
~attachment title="Container Definitions" color="darkblue"~
~json var=$task.container_definitions~
~end~
~end~
