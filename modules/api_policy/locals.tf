locals {
  resource_body = {
    properties = {
      format = var.format
      value  = var.value
    }
  }
  main_location = "unknown"
  # The GET `format` query accepts only `xml` and `rawxml`; link formats are read back inline.
  read_format = trimsuffix(var.format, "-link")
}
