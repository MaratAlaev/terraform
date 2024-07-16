resource "yandex_storage_object" "storage" {
  bucket = "marat16-07-2024"
  key    = "cat.jpg"
  source = "./cat.jpg"

  access_key = var.access_key
  secret_key = var.secret_key
}
