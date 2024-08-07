//
//  AlertManager.swift
//  login-package
//
//  Created by 밀가루 on 8/8/24.
//

import UIKit

class AlertManager {
    
    static let shared = AlertManager()
    
    private init() {}
    
    func showAlert(on viewController: UIViewController, title: String, message: String, dismissButtonTitle: String = "확인") {
        let alert = UIAlertController(title: title, message: message, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: dismissButtonTitle, style: .default, handler: nil))
        viewController.present(alert, animated: true, completion: nil)
    }
    
    func showSignInAlert(on viewController: UIViewController, message: String, delay: TimeInterval = 0.8, completion: (() -> Void)? = nil) {
        let alert = UIAlertController(title: nil, message: message, preferredStyle: .alert)
        viewController.present(alert, animated: true, completion: nil)
        
        DispatchQueue.main.asyncAfter(deadline: .now() + delay) {
            alert.dismiss(animated: true, completion: completion)
        }
    }
    
    func showSuccessAlert(on viewController: UIViewController, title: String, message: String, dismissButtonTitle: String = "확인", completion: (() -> Void)? = nil) {
        let alert = UIAlertController(title: title, message: message, preferredStyle: .alert)
        let dismissAction = UIAlertAction(title: dismissButtonTitle, style: .default) { _ in
            completion?()  // Call the completion handler when the alert is dismissed
        }
        alert.addAction(dismissAction)
        viewController.present(alert, animated: true, completion: nil)
    }
}
