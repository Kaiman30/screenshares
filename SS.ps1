Clear-Host

$primaryColor = "Cyan"
$accentColor = "Magenta"
$successColor = "Green"
$warningColor = "Yellow"
$errorColor = "Red"
$infoColor = "White"


function Show-Header {
    Clear-Host
    Write-Host @"
                ███████╗ ██████╗ ██╗      █████╗ ██████╗ 
                ██╔════╝██╔═══██╗██║     ██╔══██╗██╔══██╗
                ███████╗██║   ██║██║     ███████║██████╔╝
                ╚════██║██║   ██║██║     ██╔══██║██╔══██╗
                ███████║╚██████╔╝███████╗██║  ██║██║  ██║
                ╚══════╝ ╚═════╝ ╚══════╝╚═╝  ╚═╝╚═╝  ╚═╝
                                     
"@ -ForegroundColor $primaryColor
    Write-Host @"
 ┌──────────────────────────────────────────────────────────────────────┐ 
 │                     ScreenShares Tools Launcher                      │
 │                     Made with love by Kaiman4ik                      │
 └──────────────────────────────────────────────────────────────────────┘
"@ -ForegroundColor $accentColor

    Write-Host ""
}


$Tools = @(
    @{ Name = "Check Services";            Desc = "Check system services for work";       Url = "https://raw.githubusercontent.com/Kaiman30/screenshares/refs/heads/main/Services.ps1" },
    @{ Name = "Tools Collector";           Desc = "Download tools";                       Url = "https://raw.githubusercontent.com/Kaiman30/screenshares/refs/heads/main/Collector.ps1" },
    @{ Name = "Spokwn Collect";            Desc = "Download Spokwn tools";                Url = "https://raw.githubusercontent.com/Kaiman30/screenshares/refs/heads/main/HardDiskPaths.ps1" },
    @{ Name = "AnyDesk CVE Scanner";       Desc = "Doesnt work yet";                      Url = "https://raw.githubusercontent.com/Kaiman30/screenshares/refs/heads/main/Services.ps1" },
    @{ Name = "Signed Scheduled Tasks";    Desc = "Show table of signed tasks";           Url = "https://raw.githubusercontent.com/Kaiman30/screenshares/refs/heads/main/Signed-Scheduled-Tasks.ps1" },
    @{ Name = "System Info & Uptime";      Desc = "doesnt work yet";     Url = "https://raw.githubusercontent.com/Kaiman30/screenshares/refs/heads/main/Services.ps1" },
    @{ Name = "USN Journal Parser";        Desc = "doesnt work yet";          Url = "https://raw.githubusercontent.com/Kaiman30/screenshares/refs/heads/main/Services.ps1" },
    @{ Name = "Recycle Bin Inspector";     Desc = "doesnt work yet";     Url = "https://raw.githubusercontent.com/Kaiman30/screenshares/refs/heads/main/Services.ps1" },
    @{ Name = "PowerShell History Check";  Desc = "doesnt work yet";               Url = "https://raw.githubusercontent.com/Kaiman30/screenshares/refs/heads/main/Services.ps1" },
    @{ Name = "Event Log Analyzer";        Desc = "doesnt work yet";           Url = "https://raw.githubusercontent.com/Kaiman30/screenshares/refs/heads/main/Services.ps1" },
    @{ Name = "Prefetch Downloader";       Desc = "doesnt work yet";            Url = "https://raw.githubusercontent.com/Kaiman30/screenshares/refs/heads/main/Services.ps1" },
    @{ Name = "Device Connection Log";     Desc = "doesnt work yet";         Url = "https://raw.githubusercontent.com/Kaiman30/screenshares/refs/heads/main/Services.ps1" }
)

$half = [Math]::Ceiling($Tools.Count / 2)
$col1 = $Tools[0..($half - 1)]
$col2 = if ($Tools.Count -gt $half) { $Tools[$half..($Tools.Count - 1)] } else { @() }

# Функция отображения меню
function Show-Menu {
    Write-Host "  ➤ Select a tool to run:`n" -ForegroundColor $primaryColor
    for ($i = 0; $i -lt $half; $i++) {
        $leftNum  = $i + 1
        $rightNum = $i + 1 + $half

        $leftText  = if ($i -lt $col1.Count) { "[$leftNum] $($col1[$i].Name)" } else { "" }
        $rightText = if ($i -lt $col2.Count) { "[$rightNum] $($col2[$i].Name)" } else { "" }

        Write-Host ("  {0,-30} {1,-30}" -f $leftText, $rightText) -ForegroundColor $warningColor

        # Описание (опционально, можно закомментировать для компактности)
        $leftDesc  = if ($i -lt $col1.Count) { "      $($col1[$i].Desc)" } else { "" }
        $rightDesc = if ($i -lt $col2.Count) { "      $($col2[$i].Desc)" } else { "" }
        Write-Host ("  {0,-30} {1,-30}" -f $leftDesc, $rightDesc) -ForegroundColor DarkGray
        Write-Host ""
    }

    Write-Host "  [Q] Quit" -ForegroundColor $errorColor
    Write-Host ""
}

# Основной цикл
while ($true) {
    Show-Header
    Show-Menu

    $choice = Read-Host "  Enter your choice"
    
    if ($choice -eq "Q" -or $choice -eq "q") {
        Write-Host "`n  Goodbye! " -ForegroundColor $successColor
        Start-Sleep -Seconds 1
        Clear-Host
        break
    }

    $num = 0
    if ([int]::TryParse($choice, [ref]$num) -and $num -ge 1 -and $num -le $Tools.Count) {
        $selected = $Tools[$num - 1]
        Write-Host "`n  ➤ Running: $($selected.Name)" -ForegroundColor $warningColor
        Write-Host "    Source: $($selected.Url)`n" -ForegroundColor DarkGray

        try {
            [Net.ServicePointManager]::SecurityProtocol = [Net.SecurityProtocolType]::Tls12

            Write-Host "  Downloading script..." -ForegroundColor $infoColor
            $scriptContent = Invoke-WebRequest -Uri $selected.Url -UseBasicParsing -ErrorAction Stop

            Write-Host "  Executing script..." -ForegroundColor $successColor
            Start-Sleep -Milliseconds 500

            Clear-Host
            Invoke-Expression $scriptContent.Content

            Write-Host ""
            Write-Host "  ───────────────────────────────────" -ForegroundColor DarkGray
            Write-Host "`n  [!] Execution completed." -ForegroundColor $successColor
        }
        catch {
            Write-Host ""
            Write-Host "  ───────────────────────────────────" -ForegroundColor DarkGray
            Write-Host "`n  [X] Error: $($_.Exception.Message)" -ForegroundColor $errorColor
        }

        Write-Host "`n  Press any key to return to menu..." -ForegroundColor DarkGray
        $null = $Host.UI.RawUI.ReadKey("NoEcho,IncludeKeyDown")
    }
    else {
        Write-Host "`n  [X]  Invalid selection. Please try again." -ForegroundColor $errorColor
        Start-Sleep -Seconds 1
    }
}