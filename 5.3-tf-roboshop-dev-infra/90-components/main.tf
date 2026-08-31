module "components" {
    for_each = var.components
    source = "git::https://github.com/pandalapadu/my-AWS-DevOps-Project.git//5.3-tf-roboshop-dev-infra/tf-roboshop-components?ref=main"
    environment = var.environment
    component = each.key
    app_version = each.value.app_version
    rule_priority = each.value.rule_priority
}