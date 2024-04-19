# NIUECEOJ_test_poewershell
 用來考試監控的powershell腳本與python伺服器腳本

E608_test.ps1：

1. **開啟 Edge 瀏覽器並導航到指定網址：** 使用 `Start-Process` cmdlet 開啟 Edge 瀏覽器，並將其導向指定的網址。
2. **獲取 Edge 視窗句柄並最大化視窗並置頂：** 通過獲取 Edge 瀏覽器的視窗句柄，將其最大化並置頂。
3. **警告次數計數器和密碼設置：** 設置了一個警告次數計數器，當使用者操作不符合預期時，會觸發警告，並設置了一個密碼，用於解除對鍵盤和滑鼠的鎖定。
4. **規避 Ctrl+Alt+Del 快捷鍵：** 通過 `Register-HotKey` 註冊快捷鍵 Ctrl+Alt+Del，同時使用了 `BlockInput` 函數來阻止鍵盤和滑鼠輸入。
5. **禁用 Windows 內建快速鍵切換程式：** 通過調用 `LockWorkStation` 函數來禁用 Windows 內建的快速鍵切換程式。
6. **註冊熱鍵 Ctrl+Alt+Win+J 用於暫時啟用鍵盤輸入：** 使用 `Register-HotKey` 註冊快捷鍵 Ctrl+Alt+Win+J，用於暫時啟用鍵盤輸入。
7. **伺服器連線狀態監控：** 通過建立 TCP 連線到指定的伺服器地址和端口，以檢查伺服器連線狀態。
8. **功能函數：** 定義了一個用於啟用鍵盤的函數 `Enable-Keyboard`，以及一個用於向伺服器發送日誌信息的函數 `SendLogToServer`。

E608_test_server.py：

