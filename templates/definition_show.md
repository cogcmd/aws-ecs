~each var=$results as=definition~
~attachment title=$definition.name color="mediumblue"~
_Image:_ ~$definition.image~
~end~
~attachment title="Definition Body" color="darkblue"~
~json var=$definition~
~end~
~end~
