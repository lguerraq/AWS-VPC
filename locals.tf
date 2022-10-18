locals {
  tags = { "Servicio" : "${var.project}",
    "Ambiente" : "${var.env}"
  }
}