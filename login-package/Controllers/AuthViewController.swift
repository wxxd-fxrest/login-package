//
//  AuthViewController.swift
//  login-package
//
//  Created by 밀가루 on 8/8/24.
//

import UIKit
import CoreData
import Then

class AuthViewController: UIViewController {
    
    private let authView = AuthView()
    
    override func loadView() {
        view = authView
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupActions()
        fetchAndPrintAllUsers()
        fetchAndPrintLoggedInUser()
    }
    
    private func setupActions() {
        authView.loginButton.addTarget(self, action: #selector(signInButtonTapped), for: .touchUpInside)
    }
    
    func fetchAndPrintAllUsers() {
        let appDelegate = UIApplication.shared.delegate as! AppDelegate
        let context = appDelegate.persistentContainer.viewContext
        let fetchRequest: NSFetchRequest<User> = User.fetchRequest()

        do {
            let users = try context.fetch(fetchRequest)
            print("Auth | 모든 사용자 정보:")
            for user in users {
                print("Auth | 사용자 이름: \(user.email ?? "없음"), 비밀번호: \(user.password ?? "없음"), 로그인 상태: \(user.isLoggedIn ? "로그인 중" : "미로그인")")
            }
        } catch {
            print("데이터 가져오기 오류: \(error)")
        }
    }

    func fetchAndPrintLoggedInUser() {
        let appDelegate = UIApplication.shared.delegate as! AppDelegate
        let context = appDelegate.persistentContainer.viewContext
        let fetchRequest: NSFetchRequest<User> = User.fetchRequest()
        fetchRequest.predicate = NSPredicate(format: "isLoggedIn == %@", NSNumber(value: true))

        do {
            let loggedInUsers = try context.fetch(fetchRequest)
            if let loggedInUser = loggedInUsers.first {
                print("Auth | 현재 로그인된 사용자:")
                print("Auth | 사용자 이름: \(loggedInUser.email ?? "없음"), 비밀번호: \(loggedInUser.password ?? "없음")")
            } else {
                print("Auth | 현재 로그인된 사용자 없음")
            }
        } catch {
            print("Auth | 로그인된 사용자 데이터 가져오기 오류: \(error)")
        }
    }
    
    @objc private func signInButtonTapped() {
        guard let email = authView.emailTextField.text, !email.isEmpty,
              let password = authView.passwordTextField.text, !password.isEmpty else {
            AlertManager.shared.showAlert(on: self, title: "회원가입", message: "사용자 이름과 비밀번호를 입력해 주세요.")
            return
        }

        let hashedPassword = password.sha256()
        
        let appDelegate = UIApplication.shared.delegate as! AppDelegate
        let context = appDelegate.persistentContainer.viewContext
        let fetchRequest: NSFetchRequest<User> = User.fetchRequest()
        fetchRequest.predicate = NSPredicate(format: "email == %@", email)

        do {
            let users = try context.fetch(fetchRequest)
            if users.isEmpty {
                // 입력한 이메일이 데이터에 존재하지 않을 경우 회원가입 진행
                let newUser = User(context: context)
                newUser.email = email
                newUser.password = hashedPassword
                newUser.isLoggedIn = true // 로그인 상태 업데이트
                try context.save() // 변경 사항 저장
                
                KeychainService.savePassword(service: "MyApp", account: email, password: hashedPassword)
                // 회원가입 성공 후 알럿 표시 및 MainViewController로 이동
                AlertManager.shared.showSignInAlert(on: self, message: "회원가입을 축하드립니다.") {
                    self.navigateToMainViewController()
                }
            } else {
                // 이메일이 존재할 경우 로그인 진행
                let user = users.first!
                if user.password == hashedPassword {
                    user.isLoggedIn = true
                    try context.save()
                    // 로그인 성공 후 알럿 표시 및 MainViewController로 이동
                    AlertManager.shared.showSignInAlert(on: self, message: "로그인이 완료되었습니다.") {
                        self.navigateToMainViewController()
                    }
                } else {
                    // 비밀번호 불일치
                    AlertManager.shared.showAlert(on: self, title: "로그인", message: "이메일 또는 비밀번호가 일치하지 않습니다.")
                }
            }
        } catch {
            print("오류: \(error)")
        }
    }
    
    private func navigateToMainViewController() {
        let mainVC = MainViewController() // MainViewController를 초기화
        let navigationController = UINavigationController(rootViewController: mainVC) // 네비게이션 컨트롤러로 감싸기
        UIApplication.shared.windows.first?.rootViewController = navigationController
        UIApplication.shared.windows.first?.makeKeyAndVisible()
    }
}
