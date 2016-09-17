| Task Definition | Status |
|-----------------|--------|
~each var=$results as=task~
| ~$task.task_definition~ | ~$task.status~ |
~end~
