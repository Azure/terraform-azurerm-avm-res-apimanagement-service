param(
    [string] $TemporaryPath = [IO.Path]::GetTempPath()
)

$ErrorActionPreference = 'Stop'
$root = Split-Path $PSScriptRoot -Parent
$temporary = Join-Path $TemporaryPath "apim-publisher-tests-$([guid]::NewGuid().ToString('N'))"
$null = [IO.Directory]::CreateDirectory($temporary)
$cases = @(
    @{ Name = 'uppercase'; Environment = @{ TF_VAR_PUBLISHER_EMAIL = 'upper@example.com' }; Expected = "`nTF_VAR_publisher_email=upper@example.com`n" }
    @{ Name = 'lowercase'; Environment = @{ TF_VAR_publisher_email = 'lower@example.com' }; Expected = $null }
    @{ Name = 'missing'; Environment = @{}; Expected = $null }
    @{ Name = 'empty-uppercase'; Environment = @{ TF_VAR_PUBLISHER_EMAIL = '' }; Expected = $null }
    @{ Name = 'whitespace-uppercase'; Environment = @{ TF_VAR_PUBLISHER_EMAIL = ' ' }; Expected = $null }
    @{ Name = 'existing-dotenv'; Environment = @{ TF_VAR_PUBLISHER_EMAIL = 'upper@example.com' }; Existing = "export TF_VAR_publisher_email='file@example.com'"; Expected = "export TF_VAR_publisher_email='file@example.com'" }
    @{ Name = 'unrelated-dotenv'; Environment = @{ TF_VAR_PUBLISHER_EMAIL = 'upper@example.com' }; Existing = 'TF_VAR_other=unchanged'; Expected = "TF_VAR_other=unchanged`nTF_VAR_publisher_email=upper@example.com`n" }
    @{ Name = 'newline-rejected'; Environment = @{ TF_VAR_PUBLISHER_EMAIL = "upper@example.com`nTF_VAR_other=injected" }; Expected = $null; Fails = $true }
)
if (!$IsWindows) {
    foreach ($pair in @(@('lowercase-wins', 'lower@example.com'), @('explicit-empty-lowercase-wins', ''))) {
        $environment = [Collections.Generic.Dictionary[string, string]]::new([StringComparer]::Ordinal)
        $environment.Add('TF_VAR_PUBLISHER_EMAIL', 'upper@example.com')
        $environment.Add('TF_VAR_publisher_email', $pair[1])
        $cases += @{ Name = $pair[0]; Environment = $environment; Expected = $null }
    }
}

try {
    $passed = 0
    foreach ($case in $cases) {
        $directory = Join-Path $temporary $case.Name
        $null = [IO.Directory]::CreateDirectory($directory)
        $dotenv = Join-Path $directory '.env'
        if ($case.ContainsKey('Existing')) {
            [IO.File]::WriteAllText($dotenv, $case.Existing)
        }
        $start = [Diagnostics.ProcessStartInfo]::new([Environment]::ProcessPath)
        $start.UseShellExecute = $false
        $start.RedirectStandardOutput = $true
        $start.RedirectStandardError = $true
        foreach ($key in @($start.Environment.Keys)) {
            if ($key -match '^(TF_|ARM_|AZURE_)') {
                $null = $start.Environment.Remove($key)
            }
        }
        foreach ($key in $case.Environment.Keys) {
            $start.Environment[$key] = $case.Environment[$key]
        }
        foreach ($argument in @('-NoProfile', '-File', (Join-Path $root 'examples\prepare-publisher-email.ps1'), '-ExamplePath', $directory)) {
            $start.ArgumentList.Add($argument)
        }
        $process = [Diagnostics.Process]::Start($start)
        try {
            $stdout = $process.StandardOutput.ReadToEnd()
            $stderr = $process.StandardError.ReadToEnd()
            $process.WaitForExit()
            if (($process.ExitCode -ne 0) -ne ($case.ContainsKey('Fails') -and $case.Fails -eq $true)) {
                throw "Unexpected hook status: $($case.Name)"
            }
            if ($stdout.Length -ne 0 -or ($stderr -match 'upper@example.com|lower@example.com|file@example.com')) {
                throw "Hook exposed an input value: $($case.Name)"
            }
        } finally {
            $process.Dispose()
        }
        $actual = if (Test-Path -LiteralPath $dotenv) { [IO.File]::ReadAllText($dotenv) } else { $null }
        if ($actual -cne $case.Expected) {
            throw "Hook input precedence failed: $($case.Name)"
        }
        $passed++
    }
    $hooks = @(Get-ChildItem (Join-Path $root 'examples') -Directory | Where-Object {
        (Get-Content (Join-Path $_.FullName 'variables.tf') -Raw) -match 'variable "publisher_email"'
    })
    foreach ($example in $hooks) {
        $hook = Join-Path $example.FullName 'pre.ps1'
        if (!(Test-Path -LiteralPath $hook) -or (Get-Content $hook -Raw) -notmatch 'prepare-publisher-email\.ps1') {
            throw "Missing publisher hook: $($example.Name)"
        }
    }
    Write-Host "Publisher input tests: $passed passed; $($hooks.Count) example hooks; case-sensitive environment: $(!$IsWindows)."
} finally {
    Remove-Item -LiteralPath $temporary -Recurse -Force
}
