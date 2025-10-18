terraform {
  required_version = ">= 1.9"
  required_providers {
    azurerm = {
      source  = "hashicorp/azurerm"
      version = "~> 4.0"
    }
    random = {
      source  = "hashicorp/random"
      version = "~> 3.6"
    }
  }
}

provider "azurerm" {
  features {
    resource_group {
      prevent_deletion_if_contains_resources = false
    }
  }
}

# This ensures we have unique CAF compliant names for our resources.
module "naming" {
  source  = "Azure/naming/azurerm"
  version = "~> 0.3"
}

# This is required for resource modules
resource "azurerm_resource_group" "this" {
  location = var.location
  name     = module.naming.resource_group.name_unique
}

resource "random_string" "apim_name_suffix" {
  length  = 8
  numeric = true
  special = false
  upper   = false
}

# This is the module call
module "apim" {
  source = "../../"

  enable_telemetry    = var.enable_telemetry
  location            = azurerm_resource_group.this.location
  name                = "${module.naming.api_management.name_unique}-${random_string.apim_name_suffix.result}"
  resource_group_name = azurerm_resource_group.this.name
  publisher_email     = var.publisher_email
  publisher_name      = var.publisher_name
  sku_name            = var.sku_name

  # APIs with various policy configurations
  apis = {
    # API with rate limiting policy
    "rate-limited-api" = {
      display_name          = "Rate Limited API"
      path                  = "rate-limited"
      protocols             = ["https"]
      service_url           = "https://api.example.com"
      subscription_required = true

      # API-level policy with rate limiting
      policy = {
        xml_content = <<XML
<policies>
  <inbound>
    <base />
    <rate-limit calls="100" renewal-period="60" />
    <quota calls="10000" renewal-period="604800" />
    <cors>
      <allowed-origins>
        <origin>*</origin>
      </allowed-origins>
      <allowed-methods>
        <method>GET</method>
        <method>POST</method>
      </allowed-methods>
    </cors>
  </inbound>
  <backend>
    <base />
  </backend>
  <outbound>
    <base />
  </outbound>
  <on-error>
    <base />
  </on-error>
</policies>
XML
      }

      operations = {
        "get-data" = {
          display_name = "Get data"
          method       = "GET"
          url_template = "/data"
        }
      }
    }

    # API with JWT validation and header manipulation
    "secure-api" = {
      display_name          = "Secure API with JWT"
      path                  = "secure"
      protocols             = ["https"]
      service_url           = "https://backend.example.com"
      subscription_required = true

      # API-level policy with JWT validation
      policy = {
        xml_content = <<XML
<policies>
  <inbound>
    <base />
    <validate-jwt header-name="Authorization" failed-validation-httpcode="401" failed-validation-error-message="Unauthorized">
      <openid-config url="https://login.microsoftonline.com/common/v2.0/.well-known/openid-configuration" />
      <required-claims>
        <claim name="aud">
          <value>api://myapi</value>
        </claim>
      </required-claims>
    </validate-jwt>
    <set-header name="X-Forwarded-For" exists-action="override">
      <value>@(context.Request.IpAddress)</value>
    </set-header>
  </inbound>
  <backend>
    <base />
  </backend>
  <outbound>
    <base />
    <set-header name="X-Powered-By" exists-action="delete" />
  </outbound>
  <on-error>
    <base />
  </on-error>
</policies>
XML
      }

      operations = {
        "get-secure-data" = {
          display_name = "Get secure data"
          method       = "GET"
          url_template = "/data"
        }

        "post-secure-data" = {
          display_name = "Post secure data"
          method       = "POST"
          url_template = "/data"

          # Operation-level policy with additional validation
          policy = {
            xml_content = <<XML
<policies>
  <inbound>
    <base />
    <validate-content unspecified-content-type-action="prevent" max-size="102400" size-exceeded-action="detect">
      <content type="application/json" validate-as="json" action="prevent" />
    </validate-content>
    <set-body>@{
      var body = context.Request.Body.As<JObject>(preserveContent: true);
      body["timestamp"] = DateTime.UtcNow.ToString("o");
      return body.ToString();
    }</set-body>
  </inbound>
  <backend>
    <base />
  </backend>
  <outbound>
    <base />
  </outbound>
  <on-error>
    <base />
  </on-error>
</policies>
XML
          }
        }
      }
    }

    # API with caching and transformation
    "cached-api" = {
      display_name          = "Cached API"
      path                  = "cached"
      protocols             = ["https"]
      service_url           = "https://slow-backend.example.com"
      subscription_required = true

      # API-level policy with caching
      policy = {
        xml_content = <<XML
<policies>
  <inbound>
    <base />
    <cache-lookup vary-by-developer="false" vary-by-developer-groups="false" />
  </inbound>
  <backend>
    <base />
  </backend>
  <outbound>
    <base />
    <cache-store duration="3600" />
    <find-and-replace from="http://" to="https://" />
  </outbound>
  <on-error>
    <base />
  </on-error>
</policies>
XML
      }

      operations = {
        "get-cached-data" = {
          display_name = "Get cached data"
          method       = "GET"
          url_template = "/data/{id}"

          template_parameters = [
            {
              name     = "id"
              required = true
              type     = "string"
            }
          ]

          # Operation-level caching with vary-by parameter
          policy = {
            xml_content = <<XML
<policies>
  <inbound>
    <base />
    <cache-lookup vary-by-developer="false" vary-by-developer-groups="false">
      <vary-by-query-parameter>id</vary-by-query-parameter>
    </cache-lookup>
  </inbound>
  <backend>
    <base />
  </backend>
  <outbound>
    <base />
    <cache-store duration="7200" />
  </outbound>
  <on-error>
    <base />
  </on-error>
</policies>
XML
          }
        }
      }
    }

    # API with request/response transformation
    "transform-api" = {
      display_name          = "Transformation API"
      path                  = "transform"
      protocols             = ["https"]
      service_url           = "https://legacy-api.example.com"
      subscription_required = true

      # API-level policy with JSON to XML transformation
      policy = {
        xml_content = <<XML
<policies>
  <inbound>
    <base />
    <set-backend-service base-url="https://legacy-api.example.com/v1" />
  </inbound>
  <backend>
    <base />
  </backend>
  <outbound>
    <base />
    <xml-to-json kind="direct" apply="always" consider-accept-header="false" />
  </outbound>
  <on-error>
    <base />
  </on-error>
</policies>
XML
      }

      operations = {
        "get-transformed" = {
          display_name = "Get with transformation"
          method       = "GET"
          url_template = "/legacy"
        }
      }
    }
  }
}
