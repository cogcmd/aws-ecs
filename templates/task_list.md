~each var=$results as=task~
**Family**: ~$task.family~
**Revisions**: ~join var=$task.revisions~~$item~~end~
~br~
~end~
