locals {
  resource_body = {
    properties = {
      description = var.description
      displayName = var.display_name
      method      = var.method
      request = var.request == null ? null : {
        description = var.request.description
        headers = var.request.headers == null ? null : [
          for item in var.request.headers : {
            defaultValue = item.default_value
            description  = item.description
            name         = item.name
            required     = item.required
            schemaId     = item.schema_id
            type         = item.type
            typeName     = item.type_name
            values       = item.values
          }
        ]
        queryParameters = var.request.query_parameters == null ? null : [
          for item in var.request.query_parameters : {
            defaultValue = item.default_value
            description  = item.description
            name         = item.name
            required     = item.required
            schemaId     = item.schema_id
            type         = item.type
            typeName     = item.type_name
            values       = item.values
          }
        ]
        representations = var.request.representations == null ? null : [
          for item in var.request.representations : {
            contentType = item.content_type
            formParameters = item.form_parameters == null ? null : [
              for fp in item.form_parameters : {
                defaultValue = fp.default_value
                description  = fp.description
                name         = fp.name
                required     = fp.required
                schemaId     = fp.schema_id
                type         = fp.type
                typeName     = fp.type_name
                values       = fp.values
              }
            ]
            schemaId = item.schema_id
            typeName = item.type_name
          }
        ]
      }
      responses = var.responses == null ? null : [
        for item in var.responses : {
          description = item.description
          headers = item.headers == null ? null : [
            for h in item.headers : {
              defaultValue = h.default_value
              description  = h.description
              name         = h.name
              required     = h.required
              schemaId     = h.schema_id
              type         = h.type
              typeName     = h.type_name
              values       = h.values
            }
          ]
          representations = item.representations == null ? null : [
            for r in item.representations : {
              contentType = r.content_type
              formParameters = r.form_parameters == null ? null : [
                for fp in r.form_parameters : {
                  defaultValue = fp.default_value
                  description  = fp.description
                  name         = fp.name
                  required     = fp.required
                  schemaId     = fp.schema_id
                  type         = fp.type
                  typeName     = fp.type_name
                  values       = fp.values
                }
              ]
              schemaId = r.schema_id
              typeName = r.type_name
            }
          ]
          statusCode = item.status_code
        }
      ]
      templateParameters = var.template_parameters == null ? null : [
        for item in var.template_parameters : {
          defaultValue = item.default_value
          description  = item.description
          name         = item.name
          required     = item.required
          schemaId     = item.schema_id
          type         = item.type
          typeName     = item.type_name
          values       = item.values
        }
      ]
      urlTemplate = var.url_template
    }
  }
  main_location = "unknown"
}
