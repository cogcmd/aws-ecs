~each var=$results as=service~
~attachment title=$service.service_name color="lightblue"~
_Status:_ ~$service.status~
~end~
~attachment title="Counts" color="mediumblue"~
| Desired | Running | Pending |
| ------- | ------- | ------- |
| ~$service.desired_count~ | ~$service.running_count~ | ~$service.pending_count~ |
~end~
~attachment title="Json Body" color="darkblue"~
~json var=$service~
~end~
~end~
