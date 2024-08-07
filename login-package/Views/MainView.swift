//
//  MainView.swift
//  login-package
//
//  Created by 밀가루 on 8/8/24.
//

import UIKit
import SnapKit

class MainView: UIView {
    
    // MARK: - Properties
    private let welcomeLabel = UILabel()
    
    // MARK: - Initialization
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupView()
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        setupView()
    }
    
    // MARK: - Setup
    private func setupView() {
        backgroundColor = .white
        
        setupWelcomeLabel()
    }
    
    private func setupWelcomeLabel() {
        welcomeLabel.textAlignment = .center
        welcomeLabel.translatesAutoresizingMaskIntoConstraints = false
        addSubview(welcomeLabel)
        
        welcomeLabel.snp.makeConstraints { make in
            make.center.equalToSuperview()
        }
    }
    
    // MARK: - Public Methods
    func updateWelcomeLabel(withText text: String) {
        welcomeLabel.text = text
    }
}
