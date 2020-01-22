//
//  UItilityClass.swift
//  AlamofireExample
//
//  Created by Bhavesh Chavda on 22/01/20.
//  Copyright © 2020 BhaveshChavda. All rights reserved.
//

import Foundation
import Reachability
import NVActivityIndicatorView
import UIKit
import Toast_Swift
import Loaf


class UtilityClass: NSObject {
    //MARK: -presentViewController
    class func presentViewController(vc: UIViewController) {
        let viewController: UIViewController = (APPDELEGATE.window?.rootViewController)!
        vc.modalPresentationStyle = .overCurrentContext
        vc.popoverPresentationController?.sourceView = viewController.view
        vc.popoverPresentationController?.sourceRect = viewController.view.bounds
        vc.popoverPresentationController?.permittedArrowDirections = UIPopoverArrowDirection(rawValue: 0)
        
        if (viewController.presentedViewController != nil) {
            viewController.presentedViewController?.dismiss(animated: true, completion: {
            })
            viewController.present(vc, animated: true, completion: nil)
        } else {
            viewController.present(vc, animated: true, completion: nil)
        }
    }
    
    //MARK: -dismissViewController
    class func dismissViewController() {
        APPDELEGATE.window?.rootViewController?.dismiss(animated: true, completion: nil)
    }
    
    //MARK: -checkInternetAvailableOrNot
    class func isInternetAvailable(isAlert: Bool) -> Bool {
        let reachablity = try! Reachability.init(hostname: APIManager.shared.BaseURL)
        if reachablity.connection == .unavailable && isAlert {
            DispatchQueue.main.asyncAfter(deadline: .now() + 1) {
                UtilityClass.showToastMessage(message: "Uh-oh! Looks like you’re not connected to the internet")
                UtilityClass .removeActivityIndicator()
            }
        }
        return reachablity.connection != .unavailable
    }
}



//MARK: -AlertMessage
extension UtilityClass {
    
    //MARK: showToastMessage
    class func showToastMessage(message: String) {
        APPDELEGATE.window?.makeToast(message)
    }
    
    //MARK: showAlert
    class func showAlert(message: String?, title: String?, viewController: UIViewController? = nil) {
        UtilityClass.showAlertWithMessage(message: message, title: title, cancelButtonTitle: "OK", doneButtonTitle: nil, secondButtonTitle: nil, alertType: .alert, viewController: viewController) { (_) -> Void in }
    }
    
    //MARK: showAlertWithMessage
    class func showAlertWithMessage(message: String?, title: String?, cancelButtonTitle: String?, doneButtonTitle: String?, secondButtonTitle: String?, alertType: UIAlertController.Style, viewController: UIViewController? = nil, callback : @escaping (_ isConfirmed: Bool) -> Void) {
        let alert: UIAlertController = UIAlertController.init(title: title, message: message, preferredStyle: alertType)
        
        if cancelButtonTitle?.isEmpty == false {
            let cancelButton: UIAlertAction = UIAlertAction.init(title: cancelButtonTitle, style: .cancel) { (_) in
                // callback(false)
            }
            alert .addAction(cancelButton)
        }
        if doneButtonTitle?.isEmpty == false {
            let yesButton: UIAlertAction = UIAlertAction.init(title: doneButtonTitle, style: .default) { (_) in
                callback(true)
            }
            alert .addAction(yesButton)
        }
        
        if secondButtonTitle?.isEmpty == false {
            let thirdButton: UIAlertAction = UIAlertAction.init(title: secondButtonTitle, style: .default) { (_) in
                callback(false)
            }
            alert .addAction(thirdButton)
        }
        if viewController != nil {
            viewController?.present(alert, animated: true, completion: nil)
        } else {
            self.presentViewController(vc: alert)
        }
    }
}


//MARK: -ActivityIndicatior
extension UtilityClass {
    
    static var activityView: UIView?
    static var activityIndicatorView: NVActivityIndicatorView?
    
    //MARK: removeActivityIndicator
    class func removeActivityIndicator() {
        activityView?.isHidden = true
        activityView?.removeFromSuperview()
        activityIndicatorView?.stopAnimating()
    }
    
    //MARK: showActivityIndicator
    class func showActivityIndicator() {
        if !UtilityClass.isInternetAvailable(isAlert: false) {
            UtilityClass.removeActivityIndicator()
            return
        }
        
        guard let window = APPDELEGATE.window else { return }
        
        if let activityView = activityView {
            DispatchQueue.main.async {
                window.addSubview(activityView)
                self.activityIndicatorView? .startAnimating()
                activityView.isHidden = false
            }
            return
        }
        
        activityView = UIView(frame: MAIN_SCREEN.bounds)
        activityView?.backgroundColor = UIColor(red: 0.0, green: 0.0, blue: 0.0, alpha: 0.28)
        activityIndicatorView = NVActivityIndicatorView(frame: CGRect(x: 0, y: 0, width: 50, height: 50), type: .circleStrokeSpin, color: UIColor.black, padding: 50)
        activityIndicatorView?.center = window.center
        activityView?.addSubview(activityIndicatorView!)
        window.addSubview(activityView!)
        activityIndicatorView? .startAnimating()
        activityView?.isHidden = false
    }
}

extension Dictionary where Key: ExpressibleByStringLiteral, Value: Any {
    func string(forKey key: Key) -> String {
        guard let value = self [key] else {
            return ""
        }
        var str = ""
        // var str = String.init(format: "%ld", value as! CVarArg)
        if let v = value as? NSString {
            str = v as String
        } else if let v = value as? NSNumber {
            str = v.stringValue
        } else if let v = value as? Double {
            str = String.init(format: "%ld", v)
        } else if let v = value as? Int {
            str = String.init(format: "%i", v)
        } else if value is NSNull {
            str = ""
        } else {
            str = ""
        }
        return str
    }
    
    func bool(forKey key: Key) -> Bool {
        return self.string(forKey: key).boolValue()
    }
    
    func integer(forkey key: Key) -> Int {
        return self.string(forKey: key).integerValue()
    }
    
    func double(forkey key: Key) -> Double {
        return self.string(forKey: key).doubleValue()
    }
    
    var json: String {
        let invalidJson = "Not a valid JSON"
        do {
            let jsonData = try JSONSerialization.data(withJSONObject: self, options: .prettyPrinted)
            return String(bytes: jsonData, encoding: String.Encoding.utf8) ?? invalidJson
        } catch {
            return invalidJson
        }
    }
    
    func jsonString() -> String {
        return json
    }
}

extension Array {
    var jsonString: String {
        let invalidJson = ""
        do {
            let jsonData = try JSONSerialization.data(withJSONObject: self, options: [])
            return String(bytes: jsonData, encoding: String.Encoding.utf8) ?? invalidJson
        } catch {
            return invalidJson
        }
    }
    
    func filterDuplicates(includeElement: @escaping (_ lhs: Element, _ rhs: Element) -> Bool) -> [Element] {
        var results = [Element]()
        
        forEach { (element) in
            let existingElements = results.filter {
                return includeElement(element, $0)
            }
            if existingElements.count == 0 {
                results.append(element)
            }
        }
        
        return results
    }
}


extension FloatingPoint {
    var isInt: Bool {
        return floor(self) == self
    }
}

// MARK: Extension
extension String {
    // retun localised string
    var localisedString: String {
        return NSLocalizedString(self, comment: "")
    }
    
    var decodeEmoji: String {
        let data = self.data(using: String.Encoding.utf8)
        let decodedStr = NSString(data: data!, encoding: String.Encoding.nonLossyASCII.rawValue)
        if let str = decodedStr {
            return str as String
        }
        return self
    }
    // message to the server
    var encodeEmoji: String {
        if let encodeStr = NSString(cString: self.cString(using: .nonLossyASCII)!, encoding: String.Encoding.utf8.rawValue) {
            return encodeStr as String
        }
        return self
    }
    
    func height(withConstrainedWidth width: CGFloat, font: UIFont) -> CGFloat {
        let constraintRect = CGSize(width: width, height: .greatestFiniteMagnitude)
        let boundingBox = self.boundingRect(with: constraintRect, options: .usesLineFragmentOrigin, attributes: [NSAttributedString.Key.font: font], context: nil)
        
        return ceil(boundingBox.height)
    }
    
    func width(withConstrainedHeight height: CGFloat, font: UIFont) -> CGFloat {
        let constraintRect = CGSize(width: .greatestFiniteMagnitude, height: height)
        let boundingBox = self.boundingRect(with: constraintRect, options: .usesLineFragmentOrigin, attributes: [NSAttributedString.Key.font: font], context: nil)
        
        return ceil(boundingBox.width)
    }
    
    func lines(font: UIFont, width: CGFloat) -> Int {
        let constraintRect = CGSize(width: width, height: .greatestFiniteMagnitude)
        let boundingBox = self.boundingRect(with: constraintRect, options: .usesLineFragmentOrigin, attributes: [NSAttributedString.Key.font: font], context: nil)
        return Int(boundingBox.height / font.lineHeight)
    }
    
    func stringByStrippingHTML() -> String {
        return self.replacingOccurrences(of: "<[^>]+>", with: "", options: .regularExpression, range: nil)
    }
    
    func isEmpty() -> Bool {
        let trimmed = self.trimmingCharacters(in: NSCharacterSet.whitespacesAndNewlines)
        return trimmed.isEmpty
    }
    
    func boolValue() -> Bool {
        if self.isEmpty() {
            return false
        }
        switch self {
        case "True", "true", "yes", "1", "Y", "y":
            return true
        case "False", "false", "no", "0":
            return false
        default:
            return false
        }
    }
    
    func integerValue() -> Int {
        if let doubleValue = Double(self) {
            return doubleValue.isInt ? Int(ceil(doubleValue)) : 0
        }
        return 0
    }
    
    func doubleValue() -> Double {
        if let doubleValue = Double(self) {
            return doubleValue
        }
        return 0.0
    }
    
    func floatValues() -> Float {
        let stringValue = self
        
        if let doubleValue = Float(stringValue.replacingOccurrences(of: ",", with: "")) {
            let divisor = pow(10.0, Float(2))
            return (doubleValue * divisor).rounded() / divisor
        }
        return 0.0
    }
    
    func poundValues() -> Float {
        if let doubleValue = Float(self) {
            return doubleValue
        }
        return 0.0
    }
    
    public func isImage() -> Bool {
        // Add here your image formats.
        let imageFormats = ["jpg", "jpeg", "png", "gif"]
        
        if let ext = self.getExtension() {
            return imageFormats.contains(ext)
        }
        
        return false
    }
    
    public func getExtension() -> String? {
        let ext = (self as NSString).pathExtension
        if ext.isEmpty {
            return nil
        }
        
        return ext
    }
    
    public func isURL() -> Bool {
        return URL(string: self) != nil
    }
    
    func rightJustified(width: Int, truncate: Bool = false) -> String {
        guard width > count else {
            return truncate ? String(suffix(width)) : self
        }
        return String(repeating: " ", count: width - count) + self
    }
    
    func leftJustified(width: Int, truncate: Bool = false) -> String {
        guard width > count else {
            return truncate ? String(prefix(width)) : self
        }
        return self + String(repeating: " ", count: width - count)
    }
    
    func isNumberOnly() -> Bool {
        if self.isEmpty {
            return !self.isEmpty
        }
        let aSet = NSCharacterSet(charactersIn: "0123456789").inverted
        let compSepByCharInSet = self.components(separatedBy: aSet)
        let numberFiltered = compSepByCharInSet.joined(separator: "")
        return self == numberFiltered
    }
    
    func isStringOnly(spaceAllow: Bool) -> Bool {
        if self.isEmpty {
            return !self.isEmpty
        }
        do {
            let space = (spaceAllow == true) ? " " : ""
            let regex = try NSRegularExpression(pattern: ".*[^A-Za-z\(space)].*", options: [])
            if regex.firstMatch(in: self, options: [], range: NSRange(location: 0, length: self.count)) != nil {
                return false
            } else {
                return true
            }
        } catch {
            return false
        }
    }
    
    func isStrongPassword() -> Bool {
        var lowerCaseLetter: Bool = false
        var upperCaseLetter: Bool = false
        var digit: Bool = false
        var specialCharacter: Bool = false
        
        if self.count >= 8 {
            for char in self.unicodeScalars {
                if !lowerCaseLetter {
                    lowerCaseLetter = CharacterSet.lowercaseLetters.contains(char)
                }
                if !upperCaseLetter {
                    upperCaseLetter = CharacterSet.uppercaseLetters.contains(char)
                }
                if !digit {
                    digit = CharacterSet.decimalDigits.contains(char)
                }
                if !specialCharacter {
                    specialCharacter = CharacterSet.punctuationCharacters.contains(char)
                }
            }
            if specialCharacter || (digit && lowerCaseLetter && upperCaseLetter) {
                return true
            } else {
                return false
            }
        }
        return false
    }
    
    func date(format: String, timeZone: TimeZone = .current) -> Date? {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = format
        dateFormatter.timeZone = timeZone
        let date = dateFormatter.date(from: self)
        return date
    }
    
    func UTCdate(format: String, timeZone: TimeZone = TimeZone(abbreviation: "UTC") ?? .current) -> Date? {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = format
        dateFormatter.timeZone = timeZone
        let date = dateFormatter.date(from: self)
        return date
    }
    
    
    func getAttributedTextWithLineOfHeight(_ height: CGFloat) -> NSAttributedString {
        let attributedString = NSMutableAttributedString(string: self)
        
        // *** Create instance of `NSMutableParagraphStyle`
        let paragraphStyle = NSMutableParagraphStyle()
        
        // *** Set Alignment Center ***
        paragraphStyle.alignment = .center
        
        // *** set LineSpacing property in points ***
        paragraphStyle.lineSpacing = 2 // Whatever line spacing you want in points
        
        // *** Apply attribute to string ***
        attributedString.addAttribute(NSAttributedString.Key.paragraphStyle, value: paragraphStyle, range: NSRange(location: 0, length: attributedString.length))
        
        // *** Final Attributed String ***
        
        return attributedString
    }
    
    func isValidDecimal() -> Bool {
        let regex1: String = "^\\d+(\\.\\d{1,2})?$"
        let test1: NSPredicate = NSPredicate.init(format: "SELF MATCHES %@", regex1)
        return test1.evaluate(with: self)
    }
    
    var removingAllWhitespacesAndNewlines: String {
        return filter { !$0.isNewline && !$0.isWhitespace }
    }
    mutating func removeAllWhitespacesAndNewlines() {
        removeAll { $0.isNewline || $0.isWhitespace }
    }
}

extension Date {
    var startOfDay: Date {
        return Calendar.current.startOfDay(for: self)
    }
    
    var endOfDay: Date {
        var components = DateComponents()
        components.day = 1
        components.second = -1
        return Calendar.current.date(byAdding: components, to: startOfDay)!
    }
    
    static var yesterday: Date {
        return Calendar.current.date(byAdding: .day, value: -1, to: Date())!
    }
    static var tomorrow: Date {
        return Calendar.current.date(byAdding: .day, value: 1, to: Date())!
    }
    static var nextWeek: Date {
        return Calendar.current.date(byAdding: .day, value: 7, to: Date())!
    }
}



class Utils: NSObject {
    
    // toast
    
    func showErrorToast(viewController: UIViewController? = nil, message: String) {
        self.showToast(viewController: viewController, message: message, state: .error)
    }
    
    func showSuccessToast(viewController: UIViewController? = nil, message: String) {
        self.showToast(viewController: viewController, message: message, state: .success)
    }
    
    func showInfoToast(viewController: UIViewController? = nil, message: String) {
        self.showToast(viewController: viewController, message: message, state: .info)
    }
    
    fileprivate func showToast(viewController: UIViewController?, message: String, state: Loaf.State) {
        DispatchQueue.main.async {
            var vc = UIViewController()
            #if realApp
                vc = UIApplication.shared.topMostViewController()
            #endif
            if viewController != nil {
                vc = viewController!
            }
            
            Loaf.dismiss(sender: vc)
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
                Loaf(message, state: state, location: .bottom, sender: vc).show()
                
                DispatchQueue.main.asyncAfter(deadline: .now() + toastOnScreenTime) {
                    Loaf.dismiss(sender: vc, animated: true)
                }
            }
        }
    }
}
