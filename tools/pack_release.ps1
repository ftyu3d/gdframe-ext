# Pack dist/<id>.zip. Zip entries are addons/gdframe_<id>/...
# Usage (repo root):
#   powershell -File tools/pack_release.ps1
#   powershell -File tools/pack_release.ps1 -ExtId stream_bus

param(
	[string]$ExtId = ""
)

$ErrorActionPreference = "Stop"
$root = Split-Path -Parent $PSScriptRoot
$dist = Join-Path $root "dist"
$modules = @("stream_bus", "rumble", "input_remap")

if ($ExtId -ne "") {
	$id = $ExtId.Trim()
	if ($modules -notcontains $id) {
		throw "Unknown ext id: $id (allowed: $($modules -join ', '))"
	}
	$modules = @($id)
}

New-Item -ItemType Directory -Force -Path $dist | Out-Null

Push-Location $root
try {
	foreach ($id in $modules) {
		$rel = "addons/gdframe_$id"
		$pluginCfg = Join-Path $root "addons\gdframe_$id\plugin.cfg"
		if (-not (Test-Path $pluginCfg)) {
			throw "Missing ext dir: $rel"
		}
		$zipPath = Join-Path $dist "$id.zip"
		if (Test-Path $zipPath) {
			Remove-Item -Force $zipPath
		}
		& tar -a -c -f $zipPath $rel
		if ($LASTEXITCODE -ne 0) {
			throw "tar failed for $id"
		}
		Write-Host "Created: $zipPath"
	}
} finally {
	Pop-Location
}
