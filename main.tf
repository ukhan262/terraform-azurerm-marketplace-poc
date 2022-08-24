# 
# az vm image list --output table --all --publisher cygnalabscorp1646065782458
#

variable "common" {
  type    = string
  default = "btd"
}
variable "location" {
  type    = string
  default = "WESTUS2"
}
variable "tags" {
  default = {
    "Application" = "btdiamond"
    "Environment" = "poc"
  }
}

#networking resources
resource "azurerm_resource_group" "main" {
  name     = "marketplace-rg-${var.common}"
  location = var.location
  tags     = var.tags
}
resource "azurerm_virtual_network" "main" {
  name                = "${var.common}-network"
  address_space       = ["10.0.0.0/16"]
  location            = azurerm_resource_group.main.location
  resource_group_name = azurerm_resource_group.main.name
  tags                = var.tags
}
resource "azurerm_subnet" "main" {
  name                 = "internal"
  resource_group_name  = azurerm_resource_group.main.name
  virtual_network_name = azurerm_virtual_network.main.name
  address_prefixes     = ["10.0.2.0/24"]
}

#vm resources
module "marketplace_agreement" {
  source = "../terraform-azurerm-marketplace_agreement"
}
module "virtual_machine" {
  depends_on = [
    module.marketplace_agreement
  ]
  source              = "../terraform-azurerm-virtual_machine"
  vm_name             = "${var.common}-vm"
  location            = azurerm_resource_group.main.location
  resource_group_name = azurerm_resource_group.main.name
  vm_size             = "Standard_F4s_v2"
  subnet_id           = azurerm_subnet.main.id
  publisher           = "cygnalabscorp1646065782458"
  offer_product       = "cygnalabs-sapphire-v5"
  sku_plan            = "sapphire-v5-12"
  admin_password      = "Atomicclock99!"

  tags = var.tags
}