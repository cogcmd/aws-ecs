~each var=$results as=task~
**Family**: ~$task.family~
**Revision**: ~$task.revision~
**status**: ~$task.status~
**Task Definition ARN**: ~$task.task_definition_arn~
~if cond=$task.volumes not_empty?~
**Volumes**:
~json var=$task.volumes~
~br~
~end~
**Container Definitions**:
~json var=$task.container_definitions~
~end~
