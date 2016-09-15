| Name | ARN |
| ---- | --- |
~each var=$results as=service~
| ~$service.name~ | ~$service.arn~ |
~end~
