# Cog Bundle: ecs
Amazon EC2 Container Service Bundle

## Commands

The following commands are included with the bundle. For usage info about each command see the `help` builtin command: `help ecs:<command_name>`.

### Container definition commands

Container definitions are stored as JSON documents in a predefined S3 bucket. See configuration for details on configuring the S3 bucket.

* `ecs:container-define`

> Creates a new container definition.

* `ecs:container-update`

> Updates container definitions.

* `ecs:container-list`

> Lists container definitions.

* `ecs:container-show`

> Shows json body of a container definition.

* `ecs:container-delete`

> Deletes container definitions.

### Task commands

* `ecs:task-register`

> Registers a new task.

* `ecs:task-deregister`

> De-registers tasks.

* `ecs:task-list`

> Lists registered tasks.

* `ecs:task-show`

> Shows the task definition.

* `ecs:task-families`

> Lists task definition families.

### Service commands

* `ecs:service-create`

> Runs and maintains a desired number of tasks from a specified task definition.

* `ecs:service-delete`

> Deletes a specified service within a cluster.
> Note: The service must have a desired count and running count of 0 before you can delete it.

* `ecs:service-update`

> Modifies the desired count, deployment configuration, or task definition used in a service.

* `ecs:service-show`

> Shows a service.

* `ecs:service-list`

> Lists services running in the specified cluster.

## Configuration

### General Configuration

The preferred way of configuring `ecs` is via Cog's dynamic config. To learn more about dynamic config check out Cog's [documentation](https://cog.readme.io/docs/dynamic-command-configuration).

The `ecs` bundle defines ecs container definitions in JSON documents and stores them in pre-defined S3 locations. These locations are defined in the configuration variables below:

* `ECS_CONTAINER_DEF_URL: s3://bucket/templates`

### AWS Configuration

The easiest way to configure your AWS credentials is with the following variables set in your dynamic config:

* `AWS_REGION: us-east-1`
* `AWS_ACCESS_KEY_ID: ...`
* `AWS_SECRET_ACCESS_KEY: ...`

You can also define an STS role ARN that should be assumed:

* `AWS_STS_ROLE_ARN: "arn:aws:iam::<account_number>:role/<role_name>"`

#### Alternative Credential Configuration

If you prefer, you can configure your AWS credentials via an AWS CLI profile or an IAM instance profile.

Note: If you choose to configure your AWS credentials in this manner you will still need to configure your region via dynamic config.

* First, the bundle will look for the following environment variables:
  * `AWS_ACCESS_KEY_ID=...`
  * `AWS_SECRET_ACCESS_KEY=...`
* If those environment variables are not found, the shared AWS configuration files (`~/.aws/credentials` and `~/.aws/config`) will be used, if configured.
* Finally, the IAM instance profile will be used if the bundle is running on an AWS instance or ECS container with a profile assigned.

