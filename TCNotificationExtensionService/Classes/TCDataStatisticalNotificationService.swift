//
//  NotificationService.swift
//  NotiServiceExt
//
//  Created by 8891 on 15/06/2017.
//  Copyright © 2017 myself. All rights reserved.
//

import UserNotifications
import Alamofire
import AdSupport
import JPushExtension

class TCDataStatisticalNotificationService: UNNotificationServiceExtension {

    var contentHandler: ((UNNotificationContent) -> Void)?
    var bestAttemptContent: UNMutableNotificationContent?

    override func didReceive(_ request: UNNotificationRequest, withContentHandler contentHandler: @escaping (UNNotificationContent) -> Void) {
        self.contentHandler = contentHandler
        bestAttemptContent = (request.content.mutableCopy() as? UNMutableNotificationContent)
        
        if let bestAttemptContent = bestAttemptContent {
            // Modify the notification content here...
//            bestAttemptContent.title = "\(bestAttemptContent.title)"
//            bestAttemptContent.subtitle = "you see a modified subtitle!"
            if let imageURLStr = bestAttemptContent.userInfo["image"] as? String,
                let URL = URL(string: imageURLStr){
                downloadAndSave(url: URL) { localURL in
                    if let localURL = localURL {
                        do {
                            let attachment = try UNNotificationAttachment(identifier: "", url: localURL, options: nil)
                            bestAttemptContent.attachments = [attachment]
                        } catch {
                            print(error)
                        }
                    }
                    self.bestAttemptContent = bestAttemptContent
                    self.apnsDeliver(request)
                }
                
            }else{
                apnsDeliver(request)
            }
        }
        
        
//        self.contentHandler = contentHandler
//        bestAttemptContent = (request.content.mutableCopy() as? UNMutableNotificationContent)
//        
//        guard let bestAttemptContent = bestAttemptContent else {
//            return
//        }
//        guard let attachmentUrlString = request.content.userInfo["image"] as? String else {
//            return
//        }
//        guard let url = URL(string: attachmentUrlString) else {
//            return
//        }
//        
//        URLSession.shared.downloadTask(with: url, completionHandler: { (optLocation: URL?, optResponse: URLResponse?, error: Error?) -> Void in
//            if error != nil {
//                print("Download file error: \(String(describing: error))")
//                return
//            }
//            guard let location = optLocation else {
//                return
//            }
//            guard let response = optResponse else {
//                return
//            }
//            
//            do {
//                let lastPathComponent = response.url?.lastPathComponent ?? ""
//                var attachmentID = UUID.init().uuidString + lastPathComponent
//                
//                if response.suggestedFilename != nil {
//                    attachmentID = UUID.init().uuidString + response.suggestedFilename!
//                }
//                
//                let tempDict = NSTemporaryDirectory()
//                let tempFilePath = tempDict + attachmentID
//                
//                try FileManager.default.moveItem(atPath: location.path, toPath: tempFilePath)
//                let attachment = try UNNotificationAttachment.init(identifier: attachmentID, url: URL.init(fileURLWithPath: tempFilePath))
//                
//                bestAttemptContent.attachments.append(attachment)
//            }
//            catch {
//                print("Download file error: \(String(describing: error))")
//            }
//            
//            OperationQueue.main.addOperation({() -> Void in
//                self.contentHandler?(bestAttemptContent);
//            })
//        }).resume()
    }
    
    override func serviceExtensionTimeWillExpire() {
        // Called just before the extension will be terminated by the system.
        // Use this as an opportunity to deliver your "best attempt" at modified content, otherwise the original push payload will be used.
        if let contentHandler = contentHandler, let bestAttemptContent =  bestAttemptContent {
            contentHandler(bestAttemptContent)
        }
    }
    
    private func downloadAndSave(url: URL, handler: @escaping (_ localURL: URL?) -> Void) {
        
        
        let task = URLSession.shared.dataTask(with: url, completionHandler: {
            data, res, error in
            
            var localURL: URL? = nil
            
            if let data = data {
                let ext = (url.absoluteString as NSString).pathExtension
                let cacheURL = URL(fileURLWithPath: FileManager.default.cachesDirectory)
                let url = cacheURL.appendingPathComponent(url.absoluteString).appendingPathExtension(ext)
                
                if let _ = try? data.write(to: url) {
                    localURL = url
                }
            }
            
            handler(localURL)
        })
        
        task.resume()
    }
    
    //MARK: - JPush 統計推動到達
    private func apnsDeliver(_ request: UNNotificationRequest) -> Void {
        JPushNotificationExtensionService.jpushSetAppkey("bdd14a0c04ca0ae919e49263")
        JPushNotificationExtensionService.jpushReceive(request) {
            self.contentHandler!(self.bestAttemptContent!)
        }
        /*
         参数名        必选       类型    说明
         msg_id        是       int    推送ID
         device_id     是    string    設備ID
         platform      是    string    推送平台：android,ios,touch,pc
         type          是    string    數據類型：open：點擊，receive送達
        
         */
        //推送到達統計
        if let userInfo = bestAttemptContent?.userInfo, let tcMsgId = userInfo["msg_id"] as? String {
            let jsonData:Data = try! JSONSerialization.data(withJSONObject: ["msg_id":tcMsgId,"device_id":self.deviceUUID(),"platform":"ios","type":"receive"], options: .prettyPrinted)
            let jsonStr = String.init(data: jsonData, encoding: .utf8)!
            //同過請求body以raw傳輸json數據
            Alamofire.request("https://dc.8891.tw/api/pushDataCollection", method: .post, parameters: nil, encoding: jsonStr, headers: [:]).responseJSON {
                (response:DataResponse<Any>) in
            }

        }
//        let request = URLRequest.init(url: URL.init(string: "")!, cachePolicy: .returnCacheDataDontLoad, timeoutInterval: 10)
    }
    
   
    private func deviceUUID() -> String {
        
        let asiStr = ASIdentifierManager.shared().advertisingIdentifier.uuidString
        if asiStr.substring(to: 8) == "00000000" {
            return UIDevice.current.identifierForVendor?.uuidString ?? ""
        }else{
            return asiStr
        }
    }

}

extension String: ParameterEncoding {
    
    public func encode(_ urlRequest: URLRequestConvertible, with parameters: Parameters?) throws -> URLRequest {
        var request = try urlRequest.asURLRequest()
        request.httpBody = data(using: .utf8, allowLossyConversion: false)
        return request
    }
    
}

extension String {
    
    //substring
    func index(from: Int) -> Index {
        return self.index(startIndex, offsetBy: from)
    }
    
    func substring(from: Int) -> String {
        let fromIndex = index(from: from)
        return String(self[fromIndex...self.endIndex])
    }
    
    func substring(to: Int) -> String {
        let toIndex = index(from: to)
        return String(self[..<toIndex])
    }
}
extension FileManager {
    var cachesDirectory: String {
        var paths = NSSearchPathForDirectoriesInDomains(.cachesDirectory, .userDomainMask, true) as [String]
        return paths[0]
    }
}

//extension String {
//    var md5: String {
//
//        let data = Data(self.utf8)
//        let hash = data.withUnsafeBytes { (bytes: UnsafeRawBufferPointer) -> [UInt8] in
//            var hash = [UInt8](repeating: 0, count: Int(CC_MD5_DIGEST_LENGTH))
//            CC_MD5(bytes.baseAddress, CC_LONG(data.count), &hash)
//            return hash
//        }
//        return hash.map { String(format: "%02x", $0) }.joined()
//    }
//}

