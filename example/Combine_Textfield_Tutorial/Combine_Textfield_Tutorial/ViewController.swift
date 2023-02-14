//
//  ViewController.swift
//  Combine_Textfield_Tutorial
//
//  Created by 한빈 on 2023/02/14.
//

import UIKit
import Combine

class ViewController: UIViewController {
    @IBOutlet var passwordTextField: UITextField!
    @IBOutlet var passwordConfirmTextField: UITextField!
    @IBOutlet var myBtn: UIButton!
    
    var viewModel: MyViewModel!
    
    private var mySubscriptions = Set<AnyCancellable>()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        viewModel = MyViewModel()
        // 텍스트필드에서 나가는 이벤트를
        // ViewModel의 프로퍼티가 구독
        passwordTextField
            .myTextPublisher
        // 스레드 - 메인에서 받겠다
            .receive(on: DispatchQueue.main)
        // KVO 방식으로 구독
            .assign(to: \.passwordInput, on: viewModel)
            .store(in: &mySubscriptions)
        
        passwordConfirmTextField
            .myTextPublisher
        // 다른 쓰레드와 같이 작업 하기 때문에 RunLoop로 돌리기
            .receive(on: RunLoop.main)
        // KVO 방식으로 구독
            .assign(to: \.passwordConfirmInput, on: viewModel)
            .store(in: &mySubscriptions)
        
        // 버튼이 ViewModel의 Publisher를 구독
        viewModel.isMatchPasswordInput
            .print()
            .receive(on: RunLoop.main)
            .assign(to: \.isValid, on: myBtn)
            .store(in: &mySubscriptions)
        
    }
}

extension UITextField {
    var myTextPublisher: AnyPublisher<String, Never> {
        NotificationCenter.default.publisher(for: UITextField.textDidChangeNotification, object: self)
        // UITextField 가져옴
            .compactMap { $0.object as? UITextField }
        // String 가져옴
            .map{ $0.text ?? "" }
            .print()
            .eraseToAnyPublisher()
    }
}

extension UIButton {
    var isValid: Bool {
        get {
            backgroundColor == .yellow
        }
        set {
            backgroundColor = newValue ? .green : .lightGray
            isEnabled = newValue
            setTitleColor(newValue ? .blue : .white, for: .normal)
        }
    }
}
