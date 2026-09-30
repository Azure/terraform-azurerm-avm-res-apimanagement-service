locals {
  main_location = "unknown"
  # Null inputs are omitted so Azure keeps its defaults and the body matches a hand-written raw resource.
  pipelines = {
    for pipeline, settings in { backend   = var.backend, frontend = var.frontend } : pipeline => {
      for direction, message in { request = settings.request, response = settings.response } : direction => merge(
        message.headers == null ? {} : { headers = message.headers },
        message.body_bytes == null ? {} : { body = { bytes = message.body_bytes } },
        message.data_masking == null ? {} : {
          dataMasking = merge(
            message.data_masking.headers == null ? {} : {
              headers = [for entity in message.data_masking.headers : { mode = entity.mode, value = entity.value }]
            },
            message.data_masking.query_params == null ? {} : {
              queryParams = [for entity in message.data_masking.query_params : { mode = entity.mode, value = entity.value }]
            },
          )
        },
      ) if message != null
    } if settings != null
  }
  large_language_model = var.large_language_model == null ? null : merge(
    { logs = var.large_language_model.logs },
    {
      for direction, message in { requests = var.large_language_model.requests, responses = var.large_language_model.responses } : direction => merge(
        message.messages == null ? {} : { messages = message.messages },
        message.max_size_in_bytes == null ? {} : { maxSizeInBytes = message.max_size_in_bytes },
      ) if message != null
    },
  )
  resource_body = {
    properties = merge(
      { loggerId = var.logger_id },
      local.pipelines,
      var.always_log == null ? {} : { alwaysLog = var.always_log },
      var.http_correlation_protocol == null ? {} : { httpCorrelationProtocol = var.http_correlation_protocol },
      var.large_language_model == null ? {} : { largeLanguageModel = local.large_language_model },
      var.log_client_ip == null ? {} : { logClientIp = var.log_client_ip },
      var.metrics == null ? {} : { metrics = var.metrics },
      var.operation_name_format == null ? {} : { operationNameFormat = var.operation_name_format },
      var.sampling == null ? {} : {
        sampling = {
          percentage   = var.sampling.percentage
          samplingType = var.sampling.sampling_type
        }
      },
      var.verbosity == null ? {} : { verbosity = var.verbosity },
    )
  }
}
