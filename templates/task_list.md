~each var=$results as=task~
~attachment title=$task.family color="darkblue"~
~join var=$task.revisions~~$item~~end~
~end~
~end~
