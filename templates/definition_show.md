~each var=$results as=definition~
Name: ~$definition.name~
Image: ~$definition.image~

Definition body:
~json var=$definition~
~end~
