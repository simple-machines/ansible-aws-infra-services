# Ansible New Template

This template is divided into two sub-templates.

- infrastructure: that's where the security groups and the instances within the autoscaling groups are defined. theoritically it is managed by infrastructure teams and should contain large instances as these will run many "services". It should be detached and run separately from any projects. That means management of clusters is *centralized*.

- services: that's where the services are managed. each service definition should be a companion to the project it is deploying. That means that management of services is *decentralized*

# Getting Started

```
curl -L https://github.com/simple-machines/ansible-aws-infra-services/archive/master.tar.gz | tar zxv
mv ansible-aws-infra-services-master ansible
cd ansible
# the vault password is never committed into the repository
echo "<your vault password>" >> .vaultpassword
```

## Adding password file and edit the secret variables
### Infrastructure
To change the vault for Infrastructure it follows
./editvault.sh [cluster name] [environment]
```
# the vault password is never committed into the repository
echo "<your vault password>" >> .vaultpassword
./editvault.sh example-cluster dev
```

### Services
To change the vault for Services it follows
./editvault.sh [cluster name] [service name] [environment]
```
# the vault password is never committed into the repository
echo "<your vault password>" >> .vaultpassword
./editvault.sh example-cluster postgres-example dev
```

# Infrastructure

## Description

Infrastructures are managed in a centralized way. Each cluster should live under `infrastructure/environment/<cluster-name>`. In case of any updates the folder `infrastructure/roles` and the file `infrastructure/site.yml` are expected to change and therefore shouldn't be changed by the user.

## Directory Structure

```
cluster-name/
> infrastructure/
  > common.yml
  > dev.yml
  > prod.yml
> roles/
  > aws.ec2-autoscaling-group/
  > aws.ec2-security-groups/
infrastructure.yml
run-infrastructure.sh
```

## Update

Update of the template will be done running `infrastructure/update.sh`

## Running

Running of the template is currently done using the following:

./run-infrastructure.sh [cluster name] [environment]

```
./run-infrastructure.sh example-cluster dev
```

## Variables

Variables can be common to all environments or specific to dev/test/prod.

### Environment specific

Environment specific variables usually end by `_env` to make them distinguishable. They can look like the following:

```
aws_profile_env: "<your aws profile>"
vpc_id_env: "<vpc-you're deploying to>"
asg_launch_config_key_name_env: "<key name for your instances>"
asg_launch_config_instance_profile_name_env: "<role for your ec2 instance>"
asg_subnets_env: [<list of subnets to deploy to>]
asg_additional_security_groups_env: [<additional list of security groups id to attach>]
```

### Common

Some variables can be top level such as:

```
aws_region: "ap-southeast-2"
aws_profile: "{{ aws_profile_env }}"
vpc_id: "{{ vpc_id_env }}"
```


### Security Groups

Here you define a list of security groups (usually app specific) to attach to every ec2 instance that will boot up within the auto scaling group. Can be usually composed of an "app" security group (list of ports to allow) and an "ssh" security group. Please note that if you choose to have one security group per app (which is perfectly fine), after creating the security groups they won't be automatically attached to existing and long running instances. *This will be addressed in a future ticket*. The names of the security groups will be prepended the target cluster name

The role `aws.ec2-security-groups` expects a list under `sg_list` and a `sg_cluster_name` that look like the following:

```
sg_cluster_name: "{{ cluster_name }}"
sg_list:
  - sg_name: "TEST - SSH"
    sg_description: "TEST - SSH"
    sg_vpc_id: "{{ vpc_id }}"
    sg_region: "{{ aws_region }}"
    sg_profile: "{{ aws_profile }}"
    sg_state: present
    sg_rules:
      - proto: tcp
        from_port: 22
        to_port: 22
        cidr_ip: "12.34.56.78/32"
      - proto: tcp
        from_port: 22
        to_port: 22
        cidr_ip: "10.1.0.0/16"
```

### Auto Scaling Groups

Here you define characteristics of your security group so that instances can boot up with the right setup one would expect.

The following variables are mandatory:
```
asg_ecs_cluster_name: "{{ cluster_name }}"
asg_launch_config_key_name: "{{ asg_launch_config_key_name_env }}"
asg_subnets: "{{ asg_subnets_env }}"
asg_vpc_id: "{{ vpc_id }}"
```

The following variables are available for customization:

```
---
# defaults file for ansible-infra.aws-asg
# setup variables
asg_additional_python_pip_packages: ""
asg_additional_user_data_bootcmd: ""
asg_additional_write_files: ""
asg_additional_ecs_config: ""
asg_additional_user_data_runcmd: ""
asg_additional_cloud_config_commands: ""
asg_additional_yum_packages: ""

asg_launch_config_assign_public_ip: false
asg_min_size: 0
asg_max_size: 1
asg_desired_capacity: 1
asg_subnets: []
asg_launch_config_instance_size: "t2.small"
asg_launch_config_root_volume_size: 100

asg_additional_security_groups: [] # adding additional non tagged security groups
asg_additional_tags: []

# values to override for sure:
asg_ecs_cluster_name: ""
asg_launch_config_key_name: ""
asg_launch_config_instance_profile_name: ""
```


# Service

## Description

Services are managed in a decentralized way. Each service should live with its companion project. The roles folder are expected to change over time and therefore shouldn't be modified by the user. The same goes for `service/site.yml`

## Directory Structure

```
cluster-name/
> services/
  > service-name-1/
    > common.yml
    > dev.yml
    > prod.yml
  > service-name-2/
    > common.yml
    > dev.yml
    > prod.yml
roles/
> aws.ec2-loadbalancer/
> aws.ecs-ecr/
> aws.ecs-service/
service.yml
run-service.sh
```

## Update

Update of the template will be done running `service/update.sh`

## Running

Running of the template is currently done using the following:

run-services.sh [cluster name] [service name] [environment]

```
./run-services.sh example-cluster postgres-example dev
```

Please note that the `cluster_name` and `service_name` are set at runtime and therefore shouldn't be set within your playbooks. This guarantees consistency and enforces strict naming convention over folders.

# Services

Variables can be common (common.yml) to all environments or specific to dev/test/prod (dev.yml, test.yml, prod.yml, etc).

## ECR

To create one or more ECR repositories, place `ecr_create: true` in
`common.yml`. The module will create a new ECR repository for each
value in the `{{ ecr_repository_name }}` variable. This can either be
a single value or a list of values.

````
ecr_repository_name: "{{ service_name }}"
````

or

````
ecr_repository_name:
  - "{{ service_name }}/container1"
  - "{{ service_name }}/container2"
  - "{{ service_name }}/container3"
````

To use images in an ECR repository you might like to specify it like
so in your containter definitions:

````
  image: "{{ aws_account_id['stdout'] }}.dkr.ecr.{{ aws_region }}.amazonaws.com/{{ service_name }}:latest"
````

| variable name                   | importance | default          | description                                                                                      |
|---------------------------------|------------|------------------|--------------------------------------------------------------------------------------------------|
| ecr_repository_name             | **mandatory** |               | Name for repository *or* YAML list of names. |
| ecr_additional_aws_account_list | medium        | []            | List of additional AWS accounts to grant access to the repository. |

## ELB

To activate the creation of an ELB, place `elb_create: true` in `common.yml`.

The module will create:
- a security group for your ELB (the security group will be named `{{ elb_cluster_name }}-{{ elb_service_name }}-lb`)
- tags for that security group
- the ELB (classic) (the ELB will be named `{{ elb_cluster_name }}-{{ elb_service_name }}-lb`)

The module outputs:
- a variable named `_elb_ecs_load_balancers` containing information about the load balancer (used behind the scenes by the ecs_service module, not needed from a user perspective)

Information:
- You can find a list of defaults at [roles/aws.ec2-loadbalancer/defaults/main.yml](roles/aws.ec2-loadbalancer/defaults/main.yml)
- You can find the list of tasks at [roles/aws.ec2-loadbalancer/tasks/main.yml](roles/aws.ec2-loadbalancer/tasks/main.yml)


| variable name                   | importance | default          | description                                                                                      |
|---------------------------------|------------|------------------|--------------------------------------------------------------------------------------------------|
| elb_cluster_name                | **mandatory**  |                  | Your cluster name. You should set it to “{{ cluster_name }}”                                     |
| elb_service_name                | **mandatory**  |                  | Your cluster name. You should set it to “{{ service_name }}”                                     |
| elb_vpc_id                      | **mandatory**  |                  | The VPC id of where your ELB will be created.                                                    |
| elb_subnets                     | **mandatory**  |                  | list of subnets to deploy the ELB to,ex: [‘subnet-id1’,‘subnet-id2’]                             |
| elb_listeners                   | **mandatory**  |                  | list of listeners, see example provided orhttp://docs.ansible.com/ansible/ec2_elb_lb_module.html |
| elb_sg_rules                    | **mandatory**       | []               | List of rules for your ELB security group. Read doc at or view examples folder                   |
| elb_container_name                    | **mandatory**       |                | ECS Container name that your load balancer will be pointing to                   |
| elb_container_port                    | **mandatory**       |                | ECS Container port that your load balancer will be pointing to                   |
| elb_scheme                      | high     | internet-facing  | internal (for internal traffic), internet-facing (for external traffic)                          |
| elb_connection_draining_timeout | medium     | 60               | see http://docs.ansible.com/ansible/ec2_elb_lb_module.html doc                                   |
| elb_cross_az_load_balancing     | medium     | no               | see http://docs.ansible.com/ansible/ec2_elb_lb_module.html doc                                   |
| elb_stickiness                  | medium     |                  | see http://docs.ansible.com/ansible/ec2_elb_lb_module.html doc                                   |
| elb_health_check                | medium     |                  | see http://docs.ansible.com/ansible/ec2_elb_lb_module.html doc                                   |
| elb_access_logs                 | medium     |                  | see http://docs.ansible.com/ansible/ec2_elb_lb_module.html doc                                   |
| elb_sg_description              | low        | default/main.yml | Description of ELB security group                                                                |
| elb_sg_purge_rules              | low        | yes             | Clear out unmatched rules, should remain true                                                    |
| elb_sg_purge_rules_egress       | low        | yes             | Clear out unmatched egress rules, should remain true                                             |
| elb_idle_timeout                | low        |                  | see http://docs.ansible.com/ansible/ec2_elb_lb_module.html doc                                   |
| elb_zones                       | low        |                  | see http://docs.ansible.com/ansible/ec2_elb_lb_module.html doc                                   |


## Custom Tasks

In case you require extra components to be set-up (for example, an RDS database, an SQS queue, a SNS topic, etc...), you can write your own playbooks and have them being included automatically. Any variable registered through them will be available in your other playbooks, for example to extract an environment variable for your ECS task definition.

An example is provided as part of example-cluster [example-cluster/services/postgres-example/common.yml](example-cluster/services/postgres-example/common.yml) and [roles/custom-services/tasks/postgres-example.yml](roles/custom-services/tasks/postgres-example.yml)

Writing custom tasks is easy.
1) create the `custom_task_files` variable as an array of filenames you'd like to include
  - Example: `custom_task_files: ['my-custom-task.yml']`
2) write your custom task file in `roles/custon-services/tasks/my-custom-task.yml`
3) create variables required by the task files in `common.yml`, or `dev.yml`, etc..

Please note custom tasks are run *before* the ELB, ECR and ECS module.

### CloudWatch Log Groups

You can use the `cloudwatch_log_group.yml` custom task to create a log
group:

````
cloudwatch_log_group_name: "{{ cloudwatch_log_group_name_env }}
custom_task_files:
  - cloudwatch_log_group.yml
````

This will create a log group with the specified name and set the
`cloudwatch_log_group_arn` variable with the ARN of the log group.

# EC2 Instances Shortcuts (alias and functions)

- `dps`: shortcut for docker ps
- `dl` : get the id of running docker container
- `dlog` : get the log of the running container
- `dlogp <containername>` : get the log of the matching container name
- `dlogf` : get the tailing log of the running container. Useful to do `dlogf --tail=200`
- `dlogfp <containername>` : get the tailing log of the matching container name
- `dlogt` : get the log with timestamps of the running container
- `dlog -ft` : get the log of the running container with tailing and timestamps
- `dex <command>` : docker execute command (interactive mode) on the running container (ex: dex bash)
- `dattach`: print log as it streams (docker attach --no-stdin --sig-proxy=false)
- `dstop`: docker stop the latest container. Useful to do `dstop --time=200`
