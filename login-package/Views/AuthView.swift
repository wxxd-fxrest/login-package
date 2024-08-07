//
//  AuthView.swift
//  login-package
//
//  Created by 밀가루 on 8/8/24.
//

import UIKit
import SnapKit

class AuthView: UIView {
    
    // MARK: - Properties
    let emailTextField = UITextField().then {
        $0.placeholder = "Email"
        $0.borderStyle = .roundedRect
    }
    
    let passwordTextField = UITextField().then {
        $0.placeholder = "Password"
        $0.borderStyle = .roundedRect
        $0.isSecureTextEntry = true
    }
    
    let loginButton = UIButton().then {
        $0.setTitle("Login", for: .normal)
        $0.setTitleColor(.blue, for: .normal)
    }
    
    // MARK: - Initialization
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupUI()
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        setupUI()
    }
    
    // MARK: - Setup
    private func setupUI() {
        backgroundColor = .white
        
        addSubview(emailTextField)
        addSubview(passwordTextField)
        addSubview(loginButton)
        
        emailTextField.snp.makeConstraints { make in
            make.top.equalTo(safeAreaLayoutGuide).offset(100)
            make.left.right.equalToSuperview().inset(20)
            make.height.equalTo(40)
        }
        
        passwordTextField.snp.makeConstraints { make in
            make.top.equalTo(emailTextField.snp.bottom).offset(20)
            make.left.right.equalToSuperview().inset(20)
            make.height.equalTo(40)
        }
        
        loginButton.snp.makeConstraints { make in
            make.top.equalTo(passwordTextField.snp.bottom).offset(20)
            make.right.equalToSuperview().inset(20)
        }
    }
}
