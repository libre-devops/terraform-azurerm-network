variable "env" {
  type        = string
  description = "The env variable, for example - prd for production. normally passed via TF_VAR."
  default     = "prd"
}

variable "loc" {
  type        = string
  description = "The loc variable, for the shorthand location, e.g. uks for UK South.  Normally passed via TF_VAR."
  default     = "uks"
}

variable "short" {
  type        = string
  description = "The shorthand name of to be used in the build, e.g. cscot for CyberScot.  Normally passed via TF_VAR."
  default     = "lbdo"
}
