variable "CUR_RANGE" {
  type        = string
  default     = "daily" #daily/weekly/monthly
  description = "Accepted value is daily/weekly/monthly. This value is used as cost and usage data for last 1 day, 7 days or a month"
}

variable "REGION_NAME" {
  type        = string
  default     = "eu-west-1"
  description = "Region where the Lambda will run"
}

variable "alerts_recipients" {
  type        = list(string)
  default     = ["karanparmar2299@gmail.com"]
  description = "Recipients for the budget alerts"
}

