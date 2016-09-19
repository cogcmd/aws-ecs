| Task Definition Family | Status |
|------------------------|--------|
~each var=$results as=task~
| ~$task.task_definition_family~ | ~$task.status~ |
~end~
