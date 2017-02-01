# Ansible New Template

This template is divided into two sub-templates.

- infrastructure: that's where the security groups and the instances within the autoscaling groups are defined. theoritically it is managed by infrastructure teams and should contain large instances as these will run many "services". It should be detached and run separately from any projects. That means management of clusters is *centralized*.

- services: that's where the services are managed. each service definition should be a companion to the project it is deploying. That means that management of services is *decentralized*

# Getting Started

```
# the vault password is never committed into the repository
echo "<your vault password>" >> .vaultpassword
```

## Adding password file and edit the secret variables
### Infrastructure
To change the vault for Infrastructure it follows  
./editvault infrastructure [cluster name] [environment]
```
echo "12345">.vaultpassword  
./editvault.sh infrastructure example-cluster dev
```

### Services
To change the vault for Services it follows  
./editvault services [cluster name] [service name] [environment]
```
echo "12345">.vaultpassword  
./editvault.sh services example-cluster postgres-example dev
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

```
ansible-playbook infrastructure/site.yml -e "env=dev cluster_name=test-cluster"
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

```
ansible-playbook service/site.yml -e "env=dev cluster_name=test-cluster service_name=service-1-name"
```

Please note that the `cluster_name` and `service_name` are set at runtime and therefore shouldn't be set within your playbooks. This guarantees consistency and enforces strict naming convention over folders.

## Variables

Variables can be common to all environments or specific to dev/test/prod.

### Environment specific

TODO

### Common

TODO
