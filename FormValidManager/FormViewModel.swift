//
//  FormViewModel.swift
//  FormValidManager
//
//  Created by Alexander Römer on 11.07.21.
//

import Combine
import Foundation
import SwiftUI

enum PasswortStatus {
    case empty
    case notStrongEnough
    case repeatePasswordWrong
    case valid
}

class FormViewModel: ObservableObject {
    
    @Published var username = ""
    @Published var password = ""
    @Published var passwordAgain = ""
    @Published var inlineErrorForPassword = ""
    @Published var isValid = false
    
    private static let predicate = NSPredicate(format: "SELF MATCHES %@", "^(?=.*[a-z])(?=.*[$@$#]!%*?&]).{6,}$")
    private var cacellables = Set<AnyCancellable>()
    
    private var isUsernameValidPublisher: AnyPublisher<Bool, Never> {
        $username
            .debounce(for: 0.8, scheduler: RunLoop.main)
            .removeDuplicates()
            .map { $0.count >= 3 }
            .eraseToAnyPublisher()
    }
    
    private var isPasswordEmptyPublisher: AnyPublisher<Bool, Never> {
        $password
            .debounce(for: 0.8, scheduler: RunLoop.main)
            .removeDuplicates()
            .map { $0.count >= 3 }
            .eraseToAnyPublisher()
    }
    
    private var isPasswordStrongPublisher: AnyPublisher<Bool, Never> {
        $password
            .debounce(for: 0.8, scheduler: RunLoop.main)
            .removeDuplicates()
            .map {
                Self.predicate.evaluate(with: $0)
            }
            .eraseToAnyPublisher()
    }

    
    private var arePasswordsEqualPublisher: AnyPublisher<Bool, Never> {
        Publishers.CombineLatest($password, $passwordAgain)
            .debounce(for: 0.2, scheduler: RunLoop.main)
            .map { $0 == $1 }
            .eraseToAnyPublisher()
    }
    
    private var isPasswordValidPublisher: AnyPublisher<PasswortStatus, Never> {
        Publishers.CombineLatest3(isPasswordEmptyPublisher , isPasswordStrongPublisher, arePasswordsEqualPublisher)
            .map {
                if $0 { return PasswortStatus.empty }
                if $1 { return PasswortStatus.notStrongEnough }
                if $2 { return PasswortStatus.repeatePasswordWrong }
                return PasswortStatus.valid
            }
            .eraseToAnyPublisher()
    }
    
    private var isFormValidPublisher: AnyPublisher<Bool, Never> {
        Publishers.CombineLatest(isPasswordValidPublisher, isUsernameValidPublisher)
            .map { $0 == .valid && $1 }
            .eraseToAnyPublisher()
    }
    
    init() {
        isFormValidPublisher
            .receive(on: RunLoop.main)
            .assign(to: \.isValid, on: self)
            .store(in: &cacellables)
        
        isPasswordValidPublisher
            .dropFirst()
            .receive(on: RunLoop.main)
            .map { passwordStatus in
                switch passwordStatus {
                case .empty:
                    return "Password cannot be empty"
                case .notStrongEnough:
                    return "Password is not strong enough"
                case .repeatePasswordWrong:
                    return "Password do not match"
                case .valid:
                    return ""
                }
            }
            .assign(to: \.inlineErrorForPassword, on: self)
            .store(in: &cacellables)

    }

}
