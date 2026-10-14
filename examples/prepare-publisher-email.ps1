param(
    [Parameter(Mandatory)]
    [string] $ExamplePath
)

$ErrorActionPreference = 'Stop'
$environment = [Environment]::GetEnvironmentVariables()
foreach ($key in $environment.Keys) {
    if ([string]$key -ceq 'TF_VAR_publisher_email') {
        return
    }
}

$path = Join-Path $ExamplePath '.env'
if (Test-Path -LiteralPath $path) {
    foreach ($line in Get-Content -LiteralPath $path) {
        if ($line -cmatch '^\s*(?:export\s+)?TF_VAR_publisher_email\s*=') {
            return
        }
    }
}

$value = $null
foreach ($key in $environment.Keys) {
    if ([string]$key -ceq 'TF_VAR_PUBLISHER_EMAIL') {
        $value = [string]$environment[$key]
        break
    }
}
if ([string]::IsNullOrWhiteSpace($value)) {
    return
}
if ($value.Contains("`r") -or $value.Contains("`n")) {
    throw 'TF_VAR_PUBLISHER_EMAIL must contain a single-line value.'
}

# Hooks run in a child process; .env carries inputs to the Terraform process.
[IO.File]::AppendAllText($path, "`nTF_VAR_publisher_email=$value`n", [Text.UTF8Encoding]::new($false))
