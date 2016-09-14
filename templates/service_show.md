~each var=$results as=service~
**Service**: ~$service.name~
**Desired Count**: ~$service.desired_count~
~br~
~json var=$service~
~end~
