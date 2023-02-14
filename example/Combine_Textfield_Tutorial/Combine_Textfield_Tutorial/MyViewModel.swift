//
//  MyViewModel.swift
//  Combine_Textfield_Tutorial
//
//  Created by 한빈 on 2023/02/14.
//

import Foundation
import Combine

class MyViewModel {
    // published 어노테이션을 통해 구독이 가능하도록 설정
    @Published var passwordInput: String = "" {
        didSet {
            print("MyViewModel / passwordInput: \(passwordInput)")
        }
    }
    @Published var passwordConfirmInput: String = "" {
        didSet {
            print("MyViewModel / passwordConfirmInput: \(passwordConfirmInput)")
        }
    }
    
    lazy var isMatchPasswordInput = Publishers
        .CombineLatest($passwordInput, $passwordConfirmInput)
        .map( { (password: String, passwordConfirm: String) in
            if password == "" || passwordConfirm == "" {
                return false
            }
            if password == passwordConfirm {
                return true
            } else {
                return false
            }
        })
        .print()
        .eraseToAnyPublisher()
}
