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

1. **TCP 伺服器 Socket 創建：** 透過 `socket` 模組創建了一個 TCP 伺服器 Socket，該 Socket 監聽在特定 IP 地址和端口上（在此為 192.168.6.2:8000）。
2. **日誌資料儲存：** 使用一個 Python 字典 `logs` 來儲存日誌資料。每個 IP 地址都有一個對應的日誌條目列表。
3. **HTTP 伺服器設定：** 使用 `http.server` 模組設定了一個簡單的 HTTP 伺服器。這個伺服器將用於顯示收集到的日誌資料。
4. **日誌處理器定義：** 定義了一個自訂的 HTTP 請求處理器 `LogHandler`，用於處理 GET 請求並回傳日誌資料。
5. **TCP 伺服器主迴圈：** 主迴圈中，伺服器不斷接受連線，當連線建立後，接收從客戶端發送過來的日誌訊息。接收到日誌訊息後，將其解碼並整理成結構化的日誌條目，然後存儲到 `logs` 字典中，根據客戶端的 IP 地址進行歸類。
6. **HTTP 伺服器啟動：** 最後，使用 `HTTPServer` 啟動了 HTTP 伺服器，該伺服器會在 192.168.6.2 的 8080 端口上運行，等待 GET 請求。當收到 GET 請求時，將返回收集到的日誌資料。
