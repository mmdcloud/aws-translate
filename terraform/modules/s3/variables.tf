variable "bucket_name" {}
variable "force_destroy" {}
variable "versioning_enabled" {}
variable "objects" {
  type = list(object({
    source = string
    key    = string
  }))
  default = []
}
variable "cors" {
  type = list(object({
    allowed_headers = list(string)
    allowed_methods = list(string)
    allowed_origins = list(string)
    max_age_seconds = number
  }))
  default = []
}
variable "bucket_policy" {
  type    = string
  default = ""
}
variable "bucket_notification" {
  type = object({
    queue = list(object({
      queue_arn = string
      events    = list(string)
    }))
    lambda_function = list(object({
      lambda_function_arn = string
      events              = list(string)
    }))
  })
  default = {
    queue           = []
    lambda_function = []
  }
}
