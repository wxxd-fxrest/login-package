//
//  MainViewController.swift
//  login-package
//
//  Created by 밀가루 on 8/7/24.
//

import UIKit
import CoreData

class MainViewController: UIViewController {
    
    private let mainView = MainView()
    
    override func loadView() {
        view = mainView
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupNavigationBar() // 네비게이션 바 설정
        displayUserInfo() // 사용자 정보 표시
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.navigationController?.setNavigationBarHidden(false, animated: animated)
    }
    
    private func setupNavigationBar() {
        navigationItem.rightBarButtonItem = UIBarButtonItem(title: "설정", style: .plain, target: self, action: #selector(settingsButtonTapped))
    }
    
    private func displayUserInfo() {
        let appDelegate = UIApplication.shared.delegate as! AppDelegate
        let context = appDelegate.persistentContainer.viewContext
        let fetchRequest: NSFetchRequest<User> = User.fetchRequest()

        do {
            let users = try context.fetch(fetchRequest)
            if let user = users.first {
                print("Auth | user: Email: \(user.email ?? "N/A"), Nickname: \(user.nickname ?? "없음"), isLoggedIn: \(user.isLoggedIn)")
                // 닉네임이 비어있지 않으면 닉네임을, 그렇지 않으면 이메일을 사용하여 메시지 출력
                mainView.updateWelcomeLabel(withText: user.nickname?.isEmpty == false ? "\(user.nickname ?? user.email ?? "정보 없음") 님 환영합니다!" : "\(user.email ?? "정보 없음")님 환영합니다!")
            } else {
                mainView.updateWelcomeLabel(withText: "사용자 정보가 없습니다.")
            }
        } catch {
            print("정보 오류: \(error)")
            mainView.updateWelcomeLabel(withText: "데이터를 가져오는 중 오류 발생")
        }
    }
    
    @objc private func settingsButtonTapped() {
        let alertController = UIAlertController(title: "설정", message: "원하시는 사항을 선택하세요.", preferredStyle: .actionSheet)
        
        alertController.addAction(UIAlertAction(title: "닉네임 수정", style: .default, handler: { _ in
            self.editNicname()
        }))
        
        alertController.addAction(UIAlertAction(title: "로그아웃", style: .destructive, handler: { _ in
            self.logout()
        }))
        
        alertController.addAction(UIAlertAction(title: "회원탈퇴", style: .destructive, handler: { _ in
            self.deleteAccount()
        }))
        
        alertController.addAction(UIAlertAction(title: "취소", style: .cancel, handler: nil))
        
        present(alertController, animated: true, completion: nil)
    }
    
    private func editNicname() {
        let alertController = UIAlertController(title: "닉네임 수정", message: "새로운 닉네임을 입력하세요.", preferredStyle: .alert)
        
        alertController.addTextField { textField in
            textField.placeholder = "새로운 닉네임"
        }
        
        let saveAction = UIAlertAction(title: "저장", style: .default) { [weak self] _ in
            if let textField = alertController.textFields?.first, let newUsername = textField.text, !newUsername.isEmpty {
                // 코어 데이터에서 사용자 이름 업데이트 로직
                self?.updateUsername(newUsername)
            }
        }
        
        let cancelAction = UIAlertAction(title: "취소", style: .cancel, handler: nil)
        
        alertController.addAction(saveAction)
        alertController.addAction(cancelAction)
        
        present(alertController, animated: true, completion: nil)
    }

    private func updateUsername(_ newUsername: String) {
        let appDelegate = UIApplication.shared.delegate as! AppDelegate
        let context = appDelegate.persistentContainer.viewContext
        let fetchRequest: NSFetchRequest<User> = User.fetchRequest()
        
        do {
            let users = try context.fetch(fetchRequest)
            if let user = users.first {
                user.nickname = newUsername // 사용자 이름 업데이트
                try context.save() // 변경 사항 저장
                AlertManager.shared.showSignInAlert(on: self, message: "닉네임 수정이 완료되었습니다.") {
                    self.displayUserInfo() // 화면 업데이트
                }
            }
        } catch {
            print("닉네임 업데이트 오류: \(error)")
        }
    }
    
    private func logout() {
        let appDelegate = UIApplication.shared.delegate as! AppDelegate
        let context = appDelegate.persistentContainer.viewContext
        let fetchRequest: NSFetchRequest<User> = User.fetchRequest()

        do {
            let users = try context.fetch(fetchRequest)
            if let user = users.first {
                print("Logout | 업데이트 전 isLoggedIn 상태: \(user.isLoggedIn)")
                user.isLoggedIn = false
                try context.save()
                print("Logout | 업데이트 후 isLoggedIn 상태: \(user.isLoggedIn)")
            }
        } catch {
            print("Logout error: \(error)")
        }
        
        AlertManager.shared.showSuccessAlert(on: self, title: "로그아웃", message: "계속해서 앱을 사용하시려면 로그인을 진행해 주세요.") {
            self.navigateToAuthViewController()
        }
    }

    private func performAccountDeletion() {
        let appDelegate = UIApplication.shared.delegate as! AppDelegate
        let context = appDelegate.persistentContainer.viewContext
        let fetchRequest: NSFetchRequest<User> = User.fetchRequest()

        do {
            let users = try context.fetch(fetchRequest)
            if let user = users.first {
                context.delete(user)
                try context.save()
                print("회원 탈퇴 완료")
                AlertManager.shared.showSuccessAlert(on: self, title: "회원탈퇴 완료", message: "계정 탈퇴가 완료되었습니다.") {
                    self.navigateToAuthViewController()
                }
            }
        } catch {
            print("회원 탈퇴 오류: \(error)")
        }
    }
    
    private func deleteAccount() {
        let alertController = UIAlertController(title: "회원 탈퇴", message: "정말로 회원 탈퇴하시겠습니까?", preferredStyle: .alert)
        
        let confirmAction = UIAlertAction(title: "확인", style: .destructive) { [weak self] _ in
            self?.performAccountDeletion()
        }
        
        let cancelAction = UIAlertAction(title: "취소", style: .cancel, handler: nil)
        
        alertController.addAction(confirmAction)
        alertController.addAction(cancelAction)
        
        present(alertController, animated: true, completion: nil)
    }
    
    private func navigateToAuthViewController() {
        let loginVC = AuthViewController()
        let navigationController = UINavigationController(rootViewController: loginVC)
        
        if let window = UIApplication.shared.windows.first {
            window.rootViewController = navigationController
            window.makeKeyAndVisible()
        }
    }
}
