//
//  APIManager.swift
//  AlamofireExample
//
//  Created by Bhavesh Chavda on 22/01/20.
//  Copyright © 2020 BhaveshChavda. All rights reserved.
//


import Foundation
import Alamofire
import UIKit

typealias ResponseHandler = ((_ responseObject: [String: Any]?, _ success: Bool, _ response: HTTPURLResponse?) -> Void)?

enum ApiEnvironmentType: String {
    case development = "past your url here"
}


class APIManager: NSObject {
    
    static let shared = APIManager()
    var BaseURL = ApiEnvironmentType.development.rawValue + "api/"
    //var BaseURL = (Bundle.main.object(forInfoDictionaryKey: "BaseURL") as? String ?? "") + "api/"
    var selectedEnvironmentType: ApiEnvironmentType = ApiEnvironmentType.development // for the user external API.(For exm: slack api or other third party api)
    
    public var manager: Alamofire.SessionManager // most of your web service clients will call through sessionManager
    public var backgroundSessionManager: Alamofire.SessionManager // your web services you intend to keep running when the system backgrounds your app will use this
    private let queueApi = DispatchQueue(label: "com.queue.api", qos: DispatchQoS.userInitiated) // for manage like dislike call
    
    override init() {
        let configuration = URLSessionConfiguration.default
        self.manager = Alamofire.SessionManager(configuration: configuration)
        self.backgroundSessionManager = Alamofire.SessionManager(configuration: URLSessionConfiguration.background(withIdentifier: "com.test.ios"))
        super.init()
    }
    
    //MARK: -setApiEnviornment
    func setApiEnviornment(type: ApiEnvironmentType) {
        BaseURL = type.rawValue + "api/"
        selectedEnvironmentType = type
    }
    
    /// requesMethod
    /// - Parameters:
    ///   - url: apiEndPoint
    ///   - method: .get OR .post
    ///   - parameter: arguments
    ///   - isInternetAlert: checkAvailability
    ///   - IsServerAlert: responseAlert
    ///   - callBack: data
    func request (url: String, method: HTTPMethod, parameter: [String:Any] = [:], isInternetAlert: Bool, IsServerAlert: Bool, callBack: ResponseHandler) -> Void? {
        if !(UtilityClass.isInternetAvailable(isAlert: isInternetAlert)) {
            if let callBack = callBack {
                callBack(nil, false, nil)
            }
            return nil
        }
        let headers = ["Content-Type": "application/json"]
        debugPrint("URL:-\(BaseURL + url) -*-*-*- Parametee:-\(parameter)")
        self.manager.request(BaseURL + url, method: method, parameters: parameter, encoding: JSONEncoding.default, headers: headers).responseJSON { [weak self] response in
            self?.handleResponse(response: response, isServerAlert: IsServerAlert, callBack: callBack)
        }
        return nil
    }
    
    
    /// postImageWithParameter
    /// - Parameters:
    ///   - url: apiEndPoint
    ///   - parameter: .get OR .post
    ///   - arrImage: arguments
    ///   - arrVideo: arguments
    ///   - imageKey: arguments
    ///   - isInternetAlert: checkAvailability
    ///   - isServerAlert: responseAlert
    ///   - callback: data
    func postImageWithParameter(url: String, parameter: [String: Any], arrImage: [UIImage?], arrVideo: [URL]?, imageKey: String, isInternetAlert: Bool, isServerAlert: Bool, callback: ResponseHandler) {
        if !(UtilityClass.isInternetAvailable(isAlert: isInternetAlert)) {
            if let callBack = callback {
                callBack(nil, false, nil)
            }
        }
        
        //print("postUrl:\(url)")
        let headers = ["Content-Type": "application/json"]
        
        //        // authkey will empty while login
        //        if !UtilityClass.authenticationKey().isEmpty() {
        //            let auth_key = "Bearer " + UtilityClass.authenticationKey()
        //            headers["Authorization"] = auth_key
        //        }
        
        self.backgroundSessionManager.upload(multipartFormData: { (multipartFormData) in
            /*for (_,image) in arrImage.enumerated()
             {
             if image != nil
             {
             multipartFormData.append(UIImageJPEGRepresentation(image!, 0.8)!, withName: imageKey, fileName: "profile.jpg", mimeType: "image/jpeg")
             }
             }*/
            // for multiple images
            
            for image in arrImage where image != nil {
                multipartFormData.append(image!.jpegData(compressionQuality: 0.8)!, withName: imageKey, fileName: "image.jpg", mimeType: "image/jpeg")
                // multipartFormData.append(UIImageJPEGRepresentation(image!, 0.8)!, withName:  imageKey, fileName: "image.jpg", mimeType: "image/jpeg")
            }
            // for multiple videos
            if arrVideo != nil {
                for urll in arrVideo! {
                    multipartFormData.append(urll, withName: imageKey, fileName: "video.mp4", mimeType: "video/mp4")
                }
            }
            
            for (key, value) in parameter {
                if value is String {
                    multipartFormData.append((value as AnyObject).data(using: String.Encoding.utf8.rawValue)!, withName: key)
                } else if value is Bool {
                    multipartFormData.append((value as AnyObject).description.data(using: String.Encoding(rawValue: String.Encoding.utf8.rawValue))!, withName: key)
                }
            }
        }, to: BaseURL + url,
           headers: headers,
           encodingCompletion: { result in
            // handle response
            switch result {
            // handle  response from server
            case .success(let upload, _, _):
                upload.responseJSON { response in
                    self.handleResponse(response: response, isServerAlert: isServerAlert, callBack: callback)
                }
            // handle failure such network etc...
            case .failure(let encodingError):
                print(encodingError)
                // print("\n\nAuth request failed with error:\n \(encodingError)")
                if !(UtilityClass.isInternetAvailable(isAlert: isInternetAlert)) {
                    if let callBack = callback {
                        callBack(nil, false, nil)
                    }
                }
                UtilityClass .removeActivityIndicator()
            }
        })
    }
    
    //MARK: -handleResponse
    private func handleResponse(response: DataResponse<Any>, isServerAlert: Bool, callBack: ResponseHandler) {
        switch response.result {
        case .success:
            if let result = response.result.value {
                if  let JSON = result as? [String: Any] {
                    PRINT("\(JSON as AnyObject)")
                    if JSON.bool(forKey: "success") {
                        if let callBack = callBack {
                            callBack(JSON, true, response.response)
                        }
                    } else {
                        self.handleFailureMessage(response: response, JSON, isServerAlert: isServerAlert, callBack: callBack)
                    }
                }
            }
            
        case .failure(let error):
            PRINT("Auth request failed with error:\n \(error)")
            //UtilityClass.showAlertOnNavigationBarWith(message: error.localizedDescription, title: nil, alertType: .failure)
            if let callBack = callBack {
                callBack(nil, false, response.response)
            }
            UtilityClass .removeActivityIndicator()
        }
    }
    
    //MARK: -handleFailureMessage
    func handleFailureMessage(response: DataResponse<Any>, _ JSON: [String: Any], isServerAlert: Bool, callBack: ResponseHandler?) {
        if isServerAlert {
            if let arrMessages = JSON["message"] as? [String] {
                UtilityClass.showToastMessage(message: (arrMessages.first?.trimmingCharacters(in: .whitespacesAndNewlines)) ?? "")
            } else {
                UtilityClass.showToastMessage(message: JSON.string(forKey: "message").trimmingCharacters(in: .whitespacesAndNewlines))
            }
        }
        if let callBack = callBack {
            callBack!(JSON, false, response.response)
        }
    }
    
    //MARK: -cancelSpecificTask
    func cancelSpecificTask(byUrl url: String) {
        if let url = URL.init(string: BaseURL + url) {
            self.manager.session.getAllTasks {sessionTasks in
                print(sessionTasks.map({ $0.originalRequest?.url?.standardizedFileURL }))
                for task in sessionTasks where task.originalRequest?.url?.lastPathComponent == url.lastPathComponent {
                    task.cancel()
                }
            }
        }
    }
    
    
    let loginURL                     = "your-api-endpoint" // for example: login
    
    // MARK: - doLogin
    @discardableResult
    func doLoginWith(email: String, password: String, callBack: ResponseHandler) -> Void? {
        // parameter string
        let param = ["username": email,
                     "password": password] as [String: Any]
        return self.request(url: loginURL, method: .post, parameter: param, isInternetAlert: true, IsServerAlert: true, callBack: callBack)
    }
}
