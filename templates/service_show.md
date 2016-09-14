~each var=$results as=result~
Services:
---------
~br~
| Name | Status | Desired Count | Running Count | Pending Count |
| ---- | ------ | ------------- | ------------- | ------------- |
~each var=$result.services as=service~
| ~$service.service_name~ | ~$service.status~ | ~$service.desired_count~ | ~$service.running_count~ | ~$service.pending_count~ |
~end~
~if cond=$result.failures not_empty?~
~br~
Failures:
--------
~br~
| ARN | Reason |
| --- | ------ |
~each var=$result.failures as=failure~
| ~$failure.arn~ | ~$failure.reason~ |
~end~
~end~
~end~
