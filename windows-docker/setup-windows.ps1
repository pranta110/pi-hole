param(
    [switch] $Down
)

$ErrorActionPreference = 'Stop'
Set-Location -LiteralPath $PSScriptRoot

if (-not (Get-Command docker -ErrorAction SilentlyContinue)) {
    throw 'Docker is not installed or not on PATH. Install Docker Desktop for Windows, start it, and run this script again.'
}

if ($Down) {
    docker compose down
    exit $LASTEXITCODE
}

try {
    docker info --format '{{.ServerVersion}}' *> $null
    if ($LASTEXITCODE -ne 0) { throw 'Docker daemon is not running.' }
} catch {
    throw 'Docker Desktop is not running yet. Start Docker Desktop and run this script again.'
}

if (-not (Test-Path -LiteralPath '.env')) {
    $bytes = [byte[]]::new(32)
    $rng = [System.Security.Cryptography.RandomNumberGenerator]::Create()
    try { $rng.GetBytes($bytes) } finally { $rng.Dispose() }
    $password = [Convert]::ToBase64String($bytes)
    [System.IO.File]::WriteAllText(
        (Join-Path $PSScriptRoot '.env'),
        "PIHOLE_WEBPASSWORD=$password`r`n",
        [System.Text.UTF8Encoding]::new($false)
    )
    Write-Host 'Created .env with a random admin password. Read it with: Get-Content .env'
}

docker compose pull
if ($LASTEXITCODE -ne 0) { throw 'Could not download the Pi-hole image.' }

docker compose up -d
if ($LASTEXITCODE -ne 0) { throw 'Pi-hole did not start. Check port conflicts and Docker Desktop status.' }

Write-Host 'Pi-hole is running. Open http://localhost/admin/ and use the password in .env.'
