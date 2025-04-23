# Diagnostic Settings Example

This deploys the module with telemetry enabled and deploys azure log analytics workspace and configures the module to send logs to it.
It shows the user can specify which kind of APIM logs to send to the workspace.

Note that Diagnostic settings are not supported in all Azure regions, and we have hard coded the region to `eastus2` in this example. You can change it to your preferred region, but make sure that the region supports Diagnostic settings for APIM. 
