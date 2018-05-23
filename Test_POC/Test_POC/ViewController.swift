import UIKit
import SwiftSocket

class ViewController: UIViewController {
    
    let host = "indition.cc"
    let port = 25
    var client: TCPClient?
    
    @IBOutlet weak var conncetToServerButton: UIButton!
    @IBOutlet weak var sendDataToServerButton: UIButton!
    
    @IBOutlet weak var statusLabel: UILabel!
    override func viewDidLoad() {
        super.viewDidLoad()
        self.title = "Welcome!"
        shouldConnectView(shouldHideView: false)
        client = TCPClient(address: host, port: Int32(port))
    }
    
    
    @IBAction func conncetToServerTapped(_ sender: Any) {
        let hud = MBProgressHUD.showAdded(to: self.view, animated: true)
        hud?.dimBackground = true
        
        if conncetToServerButton.titleLabel?.text == "CONNECT" {
            DispatchQueue.global(qos: .default).async {
                self.connectToTCPClient()
            }
        }else{
            DispatchQueue.global(qos: .default).async {
                self.callServertoGetData(apiName: "quit\r\n", isLogout: true)
            }
        }
    }
    
    //MARK:- Write this code in other class and get only responce from it. since i don't get enoght time so code modularoty i have't done.
    func connectToTCPClient(){
        
        guard let client = client else {
            DispatchQueue.main.async{MBProgressHUD.hideAllHUDs(for: self.view, animated: true)}
            return
            
        }
        
        switch client.connect(timeout: 100) {
        case .success:
            shouldConnectView(shouldHideView: true)
            DispatchQueue.main.async{MBProgressHUD.hideAllHUDs(for: self.view, animated: true)}
        case .failure(let error):
            shouldConnectView(shouldHideView: false)
            showAlertView(tileOfAlert: "Failed to connnect", subTitle: error.localizedDescription)
            DispatchQueue.main.async{MBProgressHUD.hideAllHUDs(for: self.view, animated: true)}
        }
    }
    
    @IBAction func sendDataToServerTapped(_ sender: Any) {
        let hud = MBProgressHUD.showAdded(to: self.view, animated: true)
        hud?.dimBackground = true
        DispatchQueue.global(qos: .default).async {
        self.callServertoGetData(apiName: "EHLO\r\n", isLogout: false)
        }
    }
    
    func callServertoGetData(apiName: String, isLogout: Bool) {
        
        guard let client = client else { return }
        if let response = sendRequest(string: apiName, using: client) {
            parseServeresponce(string: response, isLogout: isLogout, error: "")
        }
        
    }
    
    func shouldConnectView(shouldHideView: Bool){
        
        DispatchQueue.main.async{
            MBProgressHUD.hideAllHUDs(for: self.view, animated: true)
            if shouldHideView {
                self.sendDataToServerButton.isUserInteractionEnabled = true
                self.sendDataToServerButton.backgroundColor = UIColor.blue
                self.conncetToServerButton.backgroundColor = UIColor.red
                self.statusLabel.text = "CONNECTED"
                self.conncetToServerButton.setTitle("DISCONNECT", for: .normal)
            }else{
                self.sendDataToServerButton.isUserInteractionEnabled = false
                self.sendDataToServerButton.backgroundColor = UIColor.lightGray
                self.conncetToServerButton.backgroundColor = UIColor(red: 2/255.0, green: 137/255, blue: 5/255, alpha: 1)
                self.conncetToServerButton.setTitle("CONNECT", for: .normal)
                self.statusLabel.text = "DISCONNECTED"
            }
        }
    }
    
    private func sendRequest(string: String, using client: TCPClient) -> String? {
        switch client.send(string: string) {
        case .success:
            return readResponse(from: client)
        case .failure(let error):
            showAlertView(tileOfAlert: "Failed to connnect", subTitle: error.localizedDescription)
            return nil
        }
    }
    
    private func readResponse(from client: TCPClient) -> String? {
        guard let response = client.read(1024*10) else { return nil }
        return String(bytes: response, encoding: .utf8)
    }
    
    private func parseServeresponce(string: String, isLogout: Bool, error: String) {
        
        DispatchQueue.main.async{MBProgressHUD.hideAllHUDs(for: self.view, animated: true)

        if string.count > 0 {
            
             let responceCode = string.prefix(3)
            
            if isLogout{
                
                if responceCode == "221"{
                    self.shouldConnectView(shouldHideView: false)
                }else{
                   self.showAlertView(tileOfAlert: "Failed to connnect", subTitle: error)
                }
            }else{
                
                if responceCode == "220"{
                    self.parseDataview(string: string)
                }else{
                   self.showAlertView(tileOfAlert: "Failed to connnect", subTitle: error)
                }
            }
            
        }else{
            
            self.showAlertView(tileOfAlert: "Failed to connnect", subTitle: error)
        }
        
        }
    }
    
    func parseDataview(string: String) {
        
        if string.contains("250-AUTH LOGIN "){
            
            let formatted = string.components(separatedBy: "250-AUTH LOGIN ").last
            
            debugPrint(formatted ?? "NO values");
            
            let imageNameArray = formatted?.components(separatedBy: "\r\n").first
            
            let tableListArray = imageNameArray?.components(separatedBy: " ")
            
            debugPrint(tableListArray?.count ?? "0")
            navigationToListViewScreen(tableArray: tableListArray!)
            
            
        }else{
            
            navigationToListViewScreen(tableArray: ["CRAM-SHA1", "DIGEST-MD5", "PLAIN"])
        }
    }
    
    func showAlertView(tileOfAlert: String, subTitle: String) {
        
        DispatchQueue.main.async{
        MBProgressHUD.hideAllHUDs(for: self.view, animated: true)
        let alert = UIAlertController(title: tileOfAlert, message: subTitle, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "OK", style: .default, handler: nil))
        self.present(alert, animated: true, completion: nil)
        }
    }
    
    func navigationToListViewScreen(tableArray: [String]){
        
        let listViewScreen = self.storyboard?.instantiateViewController(withIdentifier: "TableListViewController") as! TableListViewController
        listViewScreen.tableListArray = tableArray
        self.navigationController?.pushViewController(listViewScreen, animated: false)
        UIView.transition(with: (self.navigationController?.view)!, duration: 1.0, options: .transitionFlipFromLeft, animations: nil, completion: nil)
    }
}


