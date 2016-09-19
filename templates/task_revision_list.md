| Task Definition Revision | Status |
|--------------------------|--------|
~each var=$results as=task~
| ~$task.task_definition_revision~ | ~$task.status~ |
~end~

