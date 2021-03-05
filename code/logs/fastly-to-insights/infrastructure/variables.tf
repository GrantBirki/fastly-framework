# AWS Param Store Format: <serviceId1>:<serviceName1>,<serviceId2>:<serviceName2>, ...
variable "awsParamStore" {
  default = {
    value = "<serviceId1>:<serviceName1>,<serviceId2>:<serviceName2>,..."
  }
}