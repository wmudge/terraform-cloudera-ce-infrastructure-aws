# Copyright 2025 Cloudera, Inc.
#
# Licensed under the Apache License, Version 2.0 (the "License");
# you may not use this file except in compliance with the License.
# You may obtain a copy of the License at
#
#     http://www.apache.org/licenses/LICENSE-2.0
#
# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS,
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
# See the License for the specific language governing permissions and
# limitations under the License.

terraform {
  required_version = ">= 0.13"
  required_providers {
    aws = {
      source                = "hashicorp/aws",
      version               = ">= 4.60.0",
      configuration_aliases = [aws.pricing_calculator]
    }
  }
}

# provider "aws" {
#   alias  = "cost_calculator"
#   region = "us-east-1"
# }

locals {
  pricing_os_map = {
    "Red Hat Enterprise Linux" = "RHEL"
    "Red Hat BYOL Linux"       = "RHEL",
    "Ubuntu"                   = "Linux"
    "Linux/UNIX"               = "Linux"
    # "Windows"                  = "Windows"
  }
  # pricing_arch_map = {
  #   "x86_64" = "64-bit"
  #   "arm64"  = "ARM64"
  # }
}

data "aws_ami" "pvc_base" {
  filter {
    name   = "image-id"
    values = [var.image_id]
  }
}

resource "aws_instance" "pvc_base" {
  count = var.quantity == 0 ? 1 : var.quantity

  key_name      = var.ssh_key_pair
  instance_type = var.instance_type
  ami           = data.aws_ami.pvc_base.id

  subnet_id                   = var.subnet_ids[count.index % length(var.subnet_ids)]
  associate_public_ip_address = var.public_ip

  vpc_security_group_ids = var.security_groups

  root_block_device {
    delete_on_termination = var.root_volume.delete_on_termination
    volume_size           = var.root_volume.volume_size
    volume_type           = var.root_volume.volume_type
  }

  metadata_options {
    http_tokens = data.aws_ami.pvc_base.imds_support == "v2.0" ? "required" : "optional"
  }

  tags = merge(var.tags, {
    Name = var.quantity == 0 ? var.name : format("%s-%02d", var.name, count.index + var.offset + 1)
  })
}

data "aws_pricing_product" "pvc_base" {
  for_each = { for idx, instance in aws_instance.pvc_base : idx => instance }

  provider = aws.pricing_calculator

  service_code = "AmazonEC2"

  filters {
    field = "instanceType"
    value = each.value.instance_type
  }

  filters {
    field = "regionCode"
    value = each.value.region
  }

  filters {
    field = "operatingSystem"
    value = local.pricing_os_map[data.aws_ami.pvc_base.platform_details]
  }

  # filters {
  #     field = "processorArchitecture"
  #     value = local.pricing_arch_map[data.aws_ami.pvc_base.architecture]
  # }

  filters {
    field = "marketoption"
    value = "OnDemand" # TODO Review marketoption as a variable to the module
  }

  filters {
    field = "preInstalledSw"
    value = "NA"
  }

  filters {
    field = "tenancy"
    value = "Shared"
  }

  filters {
    field = "capacitystatus"
    value = "Used"
  }
}
