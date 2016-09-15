~each var=$results as=service~
**Name**: ~$service.service_name~
**Status**: ~$service.status~
**Desired Count**: ~$service.desired_count~
**Running Count**: ~$service.running_count~
**Pending Count**: ~$service.pending_count~ |
~br~
~end~
