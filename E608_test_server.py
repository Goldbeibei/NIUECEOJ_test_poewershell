import socket
import json
from datetime import datetime
from http.server import HTTPServer, BaseHTTPRequestHandler

# 儲存日誌資料
logs = {}

# 創建 TCP 伺服器 Socket
server_socket = socket.socket(socket.AF_INET, socket.SOCK_STREAM)
server_address = ('192.168.6.2', 8000)
server_socket.bind(server_address)
server_socket.listen(1)

print(f'正在監聽 {server_address[0]}:{server_address[1]}')

class LogHandler(BaseHTTPRequestHandler):
    def do_GET(self):
        self.send_response(200)
        self.send_header('Content-type', 'text/html')
        self.end_headers()
        
        html = '<html><head><title>日誌資料</title></head><body>'
        html += '<h1>日誌資料</h1>'
        html += '<table style="border-collapse: collapse; width: 100%;">'
        html += '<tr><th style="border: 1px solid #ddd; padding: 8px;">IP 地址</th><th style="border: 1px solid #ddd; padding: 8px;">日誌</th></tr>'
        
        for ip, log_entries in logs.items():
            html += f'<tr><td style="border: 1px solid #ddd; padding: 8px;">{ip}</td><td style="border: 1px solid #ddd; padding: 8px;"><pre>{json.dumps(log_entries, indent=2)}</pre></td></tr>'
        
        html += '</table></body></html>'
        self.wfile.write(html.encode())

while True:
    # 等待連線
    print('等待連線...')
    connection, client_address = server_socket.accept()

    try:
        print(f'連線自 {client_address}')

        # 接收日誌訊息
        data = b''
        while True:
            packet = connection.recv(1024)
            if not packet:
                break
            data += packet

        log_message = data.decode('utf-8')
        print(f'接收到日誌: {log_message}')

        # 整理日誌資料
        log_entry = {
            'message': log_message,
            'timestamp': datetime.now().strftime('%Y-%m-%d %H:%M:%S')
        }
        ip = client_address[0]
        if ip not in logs:
            logs[ip] = []
        logs[ip].append(log_entry)

        # 接收本地日誌並合併
        received_logs = json.loads(connection.recv(1024).decode('utf-8'))
        for log in received_logs:
            timestamp = datetime.strptime(log['Timestamp'], '%Y-%m-%d %H:%M:%S')
            log_entry = {
                'message': log['Message'],
                'timestamp': timestamp.strftime('%Y-%m-%d %H:%M:%S')
            }
            if ip not in logs:
                logs[ip] = []
            logs[ip].append(log_entry)

        # 返回合併後的日誌數據
        merged_logs = []
        for log_entries in logs.values():
            merged_logs.extend(log_entries)
        merged_logs.sort(key=lambda x: x['timestamp'], reverse=True)
        connection.sendall(json.dumps(merged_logs).encode('utf-8'))

    finally:
        # 清理連線
        connection.close()

# 啟動網頁伺服器
http_server = HTTPServer(('192.168.6.2', 8080), LogHandler)
print('啟動網頁伺服器，訪問 http://192.168.6.2:8080 查看日誌資料')
http_server.serve_forever()