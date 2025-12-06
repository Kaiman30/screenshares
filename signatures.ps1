Clear-Host
Clear-Host
Write-Host @"
 ███████╗██╗ ██████╗ ███╗   ██╗ █████╗ ████████╗██╗   ██╗██████╗ ███████╗███████╗
 ██╔════╝██║██╔════╝ ████╗  ██║██╔══██╗╚══██╔══╝██║   ██║██╔══██╗██╔════╝██╔════╝
 ███████╗██║██║  ███╗██╔██╗ ██║███████║   ██║   ██║   ██║██████╔╝█████╗  ███████╗
 ╚════██║██║██║   ██║██║╚██╗██║██╔══██║   ██║   ██║   ██║██╔══██╗██╔══╝  ╚════██║
 ███████║██║╚██████╔╝██║ ╚████║██║  ██║   ██║   ╚██████╔╝██║  ██║███████╗███████║
 ╚══════╝╚═╝ ╚═════╝ ╚═╝  ╚═══╝╚═╝  ╚═╝   ╚═╝    ╚═════╝ ╚═╝  ╚═╝╚══════╝╚══════╝                                                                              
"@ -ForegroundColor Magenta
Write-Host ""
Write-Host "  Made by spokwn kjj - " -ForegroundColor Gray -NoNewline
Write-Host -ForegroundColor DarkMagenta "spokwn"
Write-Host " -> Edited by Kaiman4ik :3" -ForegroundColor DarkMagenta
Write-Host ""

Start-Sleep -s 1
Clear-Host

function Get-DeviceMappings {
    $signature = @"
    using System;
    using System.Text;
    using System.Runtime.InteropServices;

    public class Kernel32 {
        [DllImport("kernel32.dll", SetLastError = true, CharSet = CharSet.Auto)]
        public static extern uint QueryDosDevice(
            string lpDeviceName,
            StringBuilder lpTargetPath,
            uint ucchMax
        );
    }
"@

    Add-Type -TypeDefinition $signature -ErrorAction Stop

    $Max = 65536
    $driveMappings = @()

    $volumes = Get-CimInstance -ClassName Win32_Volume -Filter "DriveLetter IS NOT NULL" -ErrorAction SilentlyContinue
    foreach ($volume in $volumes) {
        $driveLetter = "$($volume.DriveLetter)"
        $sb = New-Object System.Text.StringBuilder($Max)
        $result = [Kernel32]::QueryDosDevice($driveLetter, $sb, $Max)

        if ($result -ne 0) {
            $driveMappings += @{
                DriveLetter = $driveLetter
                DevicePath  = $sb.ToString().ToLower()
            }
        }
    }

    return $driveMappings
}

$driveMappings = Get-DeviceMappings

function Edit-DevicePaths($line, $driveMappings) {
    foreach ($driveMapping in $driveMappings) {
        $line = $line.Replace($driveMapping.DevicePath, $driveMapping.DriveLetter)
    }
    return $line
}

$possiblePathsFiles = @("Search results.txt", "paths.txt", "p.txt")
$pathsFilePath = $possiblePathsFiles | Where-Object { Test-Path $_ } | Select-Object -First 1

if (-not $pathsFilePath) {
    Write-Warning "None of the files ($($possiblePathsFiles -join ', ')) exist."
    Start-Sleep 3
    Exit
}

Try {
    $lines = Get-Content $pathsFilePath
} Catch {
    Write-Warning "Failed to read the file: $pathsFilePath"
    Start-Sleep 3
    Exit
}

$stopwatch = [Diagnostics.Stopwatch]::StartNew()
$results = @()

for ($i = 0; $i -lt $lines.Count; $i++) {
    $line = $lines[$i]

    Write-Progress -Activity "Processing lines" -Status "$($i + 1) of $($lines.Count)" -PercentComplete (($i / $lines.Count) * 100)
    $line = Edit-DevicePaths -line $line -driveMappings $driveMappings

    if ($line -match '([A-Za-z]).') {
        if ($line -match '([A-Za-z]):\\') {
            $index = $line.IndexOf($matches[0])
            if ($index -ge 0) {
                $path = $line.Substring($index)
                if (-not (Test-Path -Path $path -PathType Leaf)) {
                    $results += [pscustomobject]@{
                        Name = "DELETED"
                        Path = $line.Substring($index)
                        SignatureStatus = "DELETED"
                    }
                    continue
                }
                Try {
                    $fileName = Split-Path $path -Leaf
                    $signature = Get-AuthenticodeSignature $path 2>$null
                    $signatureStatus = $signature.Status
                    $signerName = $signature.SignerCertificate.Subject

                    if ($signerName -like "*Manthe Industries, LLC*") {
                        $signatureStatus = "NotSigned (vape client)"
                    }

                    if ($signerName -like "*Slinkware*") {
                        return "Not signed (slinky)"
                    }

                    $results += [pscustomobject]@{
                        Name = $fileName
                        Path = $path
                        SignatureStatus = $signatureStatus
                    }
                } Catch {
                    Write-Warning "Failed to obtain signature for the file: $path"
                }
            }
        }
    }
}


$stopwatch.Stop()

$time = $stopwatch.Elapsed.ToString("hh\:mm\:ss\.fff")

Write-Host "`n"
Write-Host "Scanning took $time to execute." -ForegroundColor Yellow

$results | Out-GridView -PassThru -Title 'Signature Results'