import Foundation
import Firebase
import UserNotifications

extension AppDelegate : UNUserNotificationCenterDelegate {
    
    func userNotificationCenter(_ center: UNUserNotificationCenter, willPresent notification: UNNotification, withCompletionHandler completionHandler: @escaping (UNNotificationPresentationOptions) -> Void) {
        let userInfo = notification.request.content.userInfo
        
        if let messageID = userInfo[gcmMessageIDKey] {
            print("Message ID: \(messageID)")
        }

        print(userInfo)
        
        // Change this to your preferred presentation option
        completionHandler([.alert, .sound])
    }
    
    func userNotificationCenter(_ center: UNUserNotificationCenter, didReceive response: UNNotificationResponse, withCompletionHandler completionHandler: @escaping () -> Void) {
        let userInfo = response.notification.request.content.userInfo
        
        if let messageID = userInfo[gcmMessageIDKey] {
            print("Message ID: \(messageID)")
        }
    
        print(userInfo)
        
        // Perform the task associated with the action.
        switch response.actionIdentifier {
        case "ACCEPT_ACTION":
            sendNotificationInteraction(completionHandler: completionHandler, actionQualifier: "")
            break
            
        case "DECLINE_ACTION":
            sendNotificationInteraction(completionHandler: completionHandler, actionQualifier: "")
            break
        
        case UNNotificationDismissActionIdentifier:
            sendNotificationInteraction(completionHandler: completionHandler, actionQualifier: "DISMISS")
            break
            
        case UNNotificationDefaultActionIdentifier:
            sendNotificationInteraction(completionHandler: completionHandler, actionQualifier: "OPENAPP")
            break;
            
        default:
            completionHandler()
            break
        }
    }
    
    func sendNotificationInteraction(completionHandler: @escaping() -> Void, actionQualifier: String) {
        guard let url = URL(string: "https://webhook.site/941d63e9-0176-4cc1-8dfb-cf30757b21d4")
        else {
            return
        }
        let body: [String: String] = ["actionQualifier": actionQualifier]
        let finalBody = try? JSONSerialization.data(withJSONObject: body)
        
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.httpBody = finalBody
        
        URLSession.shared.dataTask(with: request, completionHandler: { data, response, error in
            guard error == nil else {
                print(error!)
                return
            }
            
            guard let outerData = data else{
                return
            }
            
            URLSession.shared.dataTask(with: request, completionHandler: { innerData, response, error in
                guard error == nil else {
                    print(error!)
                    return
                }
                
                completionHandler()
            }).resume()
        })
        .resume()
    }
}

extension AppDelegate: MessagingDelegate {
      func messaging(_ messaging: Messaging, didReceiveRegistrationToken fcmToken: String?) {
        print("Firebase registration token: \(String(describing: fcmToken))")

        let dataDict: [String: String] = ["token": fcmToken ?? ""]
        NotificationCenter.default.post(
          name: Notification.Name("FCMToken"),
          object: nil,
          userInfo: dataDict
        )
        // TODO: If necessary send token to application server.
      }
}
