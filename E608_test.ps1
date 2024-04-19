# 開啟 Edge 瀏覽器並導航到指定網址
Start-Process "microsoft-edge:http://192.168.6.2"

# 獲取 Edge 視窗句柄
$edgeWindow = (Get-Process -Name "msedge" | Where-Object {$_.MainWindowHandle -ne 0}).MainWindowHandle

# 最大化視窗並置頂
$null = (Show-Window -Window $edgeWindow -State Maximized -Activate)

# 警告次數計數器
$warnCount = 0

# 鎖定鍵盤滑鼠的密碼
$password = "your_password_here"

# 規避 Ctrl+Alt+Del 快捷鍵
Register-HotKey -Modifiers "Control, Alt" -Key "Delete"
$signature = @'
[DllImport("user32.dll", SetLastError = true)]
public static extern bool BlockInput(bool fBlockIt);
'@
$UserInput = Add-Type -MemberDefinition $signature -Name UserInput -Namespace UserInput -PassThru

# 禁用 Windows 內建快速鍵切換程式
$signatures = @'
[DllImport("user32.dll", SetLastError=true)]
public static extern void LockWorkStation();
'@
$LockWorkStation = Add-Type -MemberDefinition $signatures -Name LockWorkStation -Namespace LockWorkStation -PassThru

# 註冊熱鍵 Ctrl+Alt+Win+J 用於暫時啟用鍵盤輸入
Register-HotKey -Modifiers "Control, Alt, Win" -Key "J"
$keyboardEnabled = $false
$keyboardTimer = $null

# 伺服器連線狀態
$serverConnected = $false
$lastDisconnectTime = $null

while ($true) {
    # 檢查是否有其他視窗遮住 Edge 或 Edge 被取消全螢幕
    $topWindow = (Get-Process | Where-Object {$_.MainWindowHandle -ne 0 -and $_.MainWindowHandle -ne $edgeWindow} | Sort-Object -Property MainWindowTitle | Select-Object -Last 1).MainWindowHandle
    $edgeState = (Get-Process -Name "msedge").MainWindowHandle
    if ($topWindow -or ($edgeState -ne $edgeWindow)) {
        $windowTitle = (Get-Process | Where-Object {$_.MainWindowHandle -eq $topWindow}).MainWindowTitle
        $wshell = New-Object -ComObject Wscript.Shell
        $wshell.Popup("警告: 您正在使用非考試軟體,警告第 $($warnCount + 1) 次。如果警告次數超過 3 次,將會鎖定鍵盤和滑鼠,需要按下 Ctrl+Alt+Win+J 後輸入密碼才能解除。", 0, "注意", 0x1)
        $warnCount++
        
        # 發送日誌到伺服器
        $logMessage = "Edge 視窗被遮擋或取消全螢幕, 警告次數: $warnCount"
        SendLogToServer $logMessage
        
        if ($warnCount -ge 3) {
            $UserInput::BlockInput($true)  # 鎖定鍵盤和滑鼠
            do {
                if ($keyboardEnabled) {
                    $password_input = $wshell.Popup("請輸入密碼解除鎖定", 0, "輸入密碼", 0x4)
                    if ($password_input -eq $password) {
                        $UserInput::BlockInput($false)  # 解除鎖定
                        $warnCount = 0
                        $keyboardEnabled = $false
                        break
                    }
                }
                Start-Sleep -Milliseconds 100
            } while ($true)
        }
    }
    
    # 監控瀏覽器訪問非預期網頁
    $edgeTabs = (Get-Process -Name "msedge" | Where-Object {$_.MainWindowHandle -ne 0}).WebBrowserNavigation.URL
    foreach ($tab in $edgeTabs) {
        if ($tab -notlike "http://192.168.6.2/*" -and $tab -ne "about:blank") {
            $logMessage = "使用者訪問了非預期網頁: $tab"
            SendLogToServer $logMessage
        }
    }
    
    # 檢查伺服器連線狀態
    try {
        $client = New-Object System.Net.Sockets.TCPClient('192.168.6.2', 8000)
        $serverConnected = $true
        $lastDisconnectTime = $null
        $logMessage = "已連線到伺服器"
        SendLogToServer $logMessage
    }
    catch {
        $serverConnected = $false
        if ($lastDisconnectTime -eq $null) {
            $lastDisconnectTime = Get-Date
            $logMessage = "與伺服器斷連"
            SendLogToServer $logMessage
        }
        else {
            $disconnectDuration = (Get-Date) - $lastDisconnectTime
            if ($disconnectDuration.TotalMinutes -ge 1) {
                $UserInput::BlockInput($true)  # 鎖定鍵盤和滑鼠
                $wshell.Popup("已與伺服器斷連超過 1 分鐘,鍵盤和滑鼠已被鎖定。請按下 Ctrl+Alt+Win+J 後輸入密碼解除鎖定,或重新連線到伺服器。", 0, "注意", 0x1)
                do {
                    if ($keyboardEnabled) {
                        $password_input = $wshell.Popup("請輸入密碼解除鎖定", 0, "輸入密碼", 0x4)
                        if ($password_input -eq $password) {
                            $UserInput::BlockInput($false)  # 解除鎖定
                            $lastDisconnectTime = $null
                            break
                        }
                    }
                    Start-Sleep -Milliseconds 100
                } while ($true)
            }
        }
    }
    
    Start-Sleep -Milliseconds 100
}

function Enable-Keyboard {
    $keyboardEnabled = $true
    $keyboardTimer = [System.Threading.Timer]::New({
        $keyboardEnabled = $false
    }, $null, 10000, -1)
}

function SendLogToServer($message) {
    try {
        $bytes = [System.Text.Encoding]::UTF8.GetBytes($message)
        $client = New-Object System.Net.Sockets.TCPClient('192.168.6.2', 8000)
        $stream = $client.GetStream()
        $stream.Write($bytes, 0, $bytes.Length)
        $stream.Flush()
        $client.Close()
    }
    catch {
        # 捕獲連線失敗的異常
    }
}

Register-HotKey -Modifiers "Control, Alt, Win" -Key "J" -Action { Enable-Keyboard }