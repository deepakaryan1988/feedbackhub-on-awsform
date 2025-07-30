variable "project_name" {}
variable "ecs_cluster_id" {}
variable "task_definition_arn" {}
variable "subnet_ids" {
  type = list(string)
}
variable "security_group_id" {}
variable "green_target_group_arn" {}
variable "container_name" {}
variable "container_port" {}
