//
//  ViewController.swift
//  KeyboardTest
//
//  Created by Марат Саляхетдинов on 08.03.2024.
//

import UIKit

struct TestMessageModel {
    let message: String
    let isMine: Bool
}

protocol ComposeBarDelegate: AnyObject {
    func didSend(_ model: TestMessageModel)
    func didBeginEditing()
}

final class ComposeBar: UIView {
    
    weak var delegate: ComposeBarDelegate?
    
    private let textView: UITextView = {
       let view = UITextView()
        view.translatesAutoresizingMaskIntoConstraints = false
        view.backgroundColor = .lightGray
        return view
    }()
    
    private let sendButton: UIButton = {
       let view = UIButton()
        view.translatesAutoresizingMaskIntoConstraints = false
        view.clipsToBounds = true
        view.setTitle("S", for: .normal)
        view.layer.cornerRadius = 15
        view.backgroundColor = .blue
        return view
    }()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        settings()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    @objc private func sendMessage() {
        let textMessage = textView.text!
        
        let model = TestMessageModel(message: textMessage, isMine: Bool.random())
        
        delegate?.didSend(model)
        
        textView.text = ""
        
    }

    private func settings() {
        addSubview(textView)
        addSubview(sendButton)
        
        textView.delegate = self

        NSLayoutConstraint.activate([
            textView.leadingAnchor.constraint(equalTo: leadingAnchor),
            textView.topAnchor.constraint(equalTo: topAnchor),
            textView.bottomAnchor.constraint(equalTo: bottomAnchor),
            textView.heightAnchor.constraint(equalToConstant: 30),
            
            sendButton.widthAnchor.constraint(equalToConstant: 30),
            sendButton.heightAnchor.constraint(equalToConstant: 30),
            sendButton.topAnchor.constraint(equalTo: topAnchor),
            sendButton.trailingAnchor.constraint(equalTo: trailingAnchor),
            sendButton.bottomAnchor.constraint(equalTo: bottomAnchor),
            
            textView.trailingAnchor.constraint(equalTo: sendButton.leadingAnchor),
        ])
        
        sendButton.addTarget(self, action: #selector(sendMessage), for: .touchUpInside)
    }
}

extension ComposeBar: UITextViewDelegate {
    func textViewDidBeginEditing(_ textView: UITextView) {
        textView.becomeFirstResponder()
        delegate?.didBeginEditing()
    }
}

final class ViewController: UIViewController {

    var model: [TestMessageModel] = (0...30).map { TestMessageModel(message: "\($0)", isMine: $0 % 2 == 0)}
    
    private let textView: ComposeBar = {
       let view = ComposeBar()
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()
    
    private let tableView: UITableView = {
       let view = UITableView()
        view.translatesAutoresizingMaskIntoConstraints = false
        view.register(UITableViewCell.self, forCellReuseIdentifier: "s")
        return view
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        settings()
    }

    private func settings() {
        view.addSubview(textView)
        view.addSubview(tableView)
        
        tableView.allowsKeyboardScrolling = true
        tableView.dataSource = self
        textView.delegate = self
        
        tableView.keyboardDismissMode = .interactive
        
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillShow), name: UIResponder.keyboardWillShowNotification, object: nil)
        
//        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillHide), name: UIResponder.keyboardDidHideNotification, object: nil)
        
        view.keyboardLayoutGuide.followsUndockedKeyboard = true
        
        NSLayoutConstraint.activate([
            textView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            textView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            textView.bottomAnchor.constraint(equalTo: view.keyboardLayoutGuide.topAnchor, constant: -10),
            textView.heightAnchor.constraint(equalToConstant: 30),
            
            
            tableView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
            tableView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            tableView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            tableView.bottomAnchor.constraint(equalTo: textView.topAnchor),
        ])
    }
    
    @objc func keyboardWillShow(_ note: Notification) {
        let beginFrame = (note.userInfo![UIResponder.keyboardFrameBeginUserInfoKey] as! NSValue).cgRectValue
        let endFrame = (note.userInfo![UIResponder.keyboardFrameEndUserInfoKey] as! NSValue).cgRectValue
        let delta = (endFrame.origin.y - beginFrame.origin.y)
        
        tableView.contentOffset = CGPoint(x: tableView.contentOffset.x, y: tableView.contentOffset.y - delta - 30)
    }

}

extension ViewController: ComposeBarDelegate {
    func didSend(_ model: TestMessageModel) {
        self.model.append(model)
        tableView.reloadData()
        
    }
    
    func didBeginEditing() {
        

    }
}

extension ViewController: UITableViewDataSource {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        model.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "s", for: indexPath)
        let model = model[indexPath.row]
        
        cell.textLabel?.text = model.message
        cell.backgroundColor = model.isMine ? .green : .red
        
        cell.textLabel?.textAlignment = model.isMine ? .left : .right
        return cell
    }
    
    
}
