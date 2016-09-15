~each var=$results as=service~
**Service**: ~$service.service_name~
**Desired Count**: ~$service.desired_count~
~br~
~json var=$service~
~end~
