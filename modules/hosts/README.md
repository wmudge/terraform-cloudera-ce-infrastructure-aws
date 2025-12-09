<!-- BEGIN_TF_DOCS -->
# Terraform Module for AWS Hosts

The `hosts` module contains resource files to provision and manage AWS EC2 instances with flexible configuration options for compute resources, storage volumes, and networking. This module is designed for Cloudera on premise infrastructure deployments on AWS IaaS but can be used for any AWS EC2 instance provisioning needs.

## Key Features

- **Flexible Instance Provisioning**: Create single instances or multiple identical nodes with sequential naming
- **Custom Storage Configuration**: Attach and manage additional EBS volumes with configurable size, type, and mount points
- **Network Integration**: Place instances in specific subnets with optional public IP assignment
- **Security Management**: Apply security groups to control access to instances
- **Resource Tagging**: Add custom tags to all provisioned resources for better organization and cost management
- **IMDSv2 Support**: Automatic detection and configuration of IMDSv2 tokens based on AMI capabilities

## Usage

The [examples](./examples) directory has example of using this module:

* `ex01-minimal_inputs` demonstrates how this module can be used to create a number of EC2 instances. The [terraform-aws-network](../terraform-aws-network/README.md) module is also used as part of this example.

The sample `terraform.tfvars.sample` describes the required inputs for the example.

## Requirements

| Name | Version |
|------|---------|
| <a name="requirement_terraform"></a> [terraform](#requirement\_terraform) | >= 0.13 |
| <a name="requirement_aws"></a> [aws](#requirement\_aws) | >= 4.60.0 |

## Providers

| Name | Version |
|------|---------|
| <a name="provider_aws"></a> [aws](#provider\_aws) | >= 4.60.0 |
| <a name="provider_aws.pricing_calculator"></a> [aws.pricing\_calculator](#provider\_aws.pricing\_calculator) | >= 4.60.0 |

## Modules

No modules.

## Resources

| Name | Type |
|------|------|
| [aws_ebs_volume.inventory](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/ebs_volume) | resource |
| [aws_instance.pvc_base](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/instance) | resource |
| [aws_volume_attachment.inventory](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/volume_attachment) | resource |
| [aws_ami.pvc_base](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/ami) | data source |
| [aws_pricing_product.pvc_base](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/pricing_product) | data source |

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| <a name="input_image_id"></a> [image\_id](#input\_image\_id) | AMI image ID for the hosts | `string` | n/a | yes |
| <a name="input_name"></a> [name](#input\_name) | Instance name. If 'quantity' is set, name will be <name>-NN. | `string` | n/a | yes |
| <a name="input_security_groups"></a> [security\_groups](#input\_security\_groups) | List of security group IDs to attach to the instances | `list(string)` | n/a | yes |
| <a name="input_ssh_key_pair"></a> [ssh\_key\_pair](#input\_ssh\_key\_pair) | SSH key pair name | `string` | n/a | yes |
| <a name="input_subnet_ids"></a> [subnet\_ids](#input\_subnet\_ids) | List of subnet IDs to provision the instances | `list(string)` | n/a | yes |
| <a name="input_instance_type"></a> [instance\_type](#input\_instance\_type) | Instance type name for the hosts | `string` | `"t2.micro"` | no |
| <a name="input_offset"></a> [offset](#input\_offset) | Number offset for instance name | `number` | `0` | no |
| <a name="input_public_ip"></a> [public\_ip](#input\_public\_ip) | Flag to assign public IP addresses to the hosts | `bool` | `false` | no |
| <a name="input_quantity"></a> [quantity](#input\_quantity) | Number of instances. Defaults to a single instance without numbering (bare name). | `number` | `0` | no |
| <a name="input_root_volume"></a> [root\_volume](#input\_root\_volume) | Root volume details | <pre>object({<br/>    delete_on_termination = optional(bool, true)<br/>    volume_size           = optional(number, 100)<br/>    volume_type           = optional(string)<br/>  })</pre> | `{}` | no |
| <a name="input_tags"></a> [tags](#input\_tags) | Map of tags applied to all cloud-provider assets. | `map(any)` | `{}` | no |
| <a name="input_volumes"></a> [volumes](#input\_volumes) | Additional storage volumes to attach to the hosts. Each volume is defined by a device name, mount point, size, type, and optional tags. | <pre>list(object({<br/>    device_name = string<br/>    mount       = string<br/>    volume_size = optional(number, 100)<br/>    volume_type = optional(string, "gp2")<br/>    tags        = optional(map(string), {})<br/>    }<br/>    )<br/>  )</pre> | `null` | no |

## Outputs

| Name | Description |
|------|-------------|
| <a name="output_hosts"></a> [hosts](#output\_hosts) | Hosts |
| <a name="output_pricing"></a> [pricing](#output\_pricing) | The hourly cost and details for each instance of this module. |
| <a name="output_storage_volumes"></a> [storage\_volumes](#output\_storage\_volumes) | Additional Storage Volumes |
<!-- END_TF_DOCS -->