//
//  NoteViewController.swift
//  testApplcation
//
//  Created by Влад on 18.03.2022.
//

import UIKit
import CoreData

struct NoteEditingViewModel {
    let title: String
    let text: NSAttributedString
    let date: String
}

protocol INoteEditingViewController: AnyObject {
    func configure(with model: NoteEditingViewModel)
    func showAlert(with error: Error)
    func close()
}

class NoteEditingViewController: UIViewController {
    
    // MARK: - Dependencies
    
    private let presenter: INoteEditingPresenter
    
    // MARK: - UI Elements
    
    private lazy var textView: UITextView = {
        let textView = UITextView()
        textView.font = .systemFont(ofSize: 15.0)
        textView.translatesAutoresizingMaskIntoConstraints = false
        textView.allowsEditingTextAttributes = true
        return textView
    }()
    
    private lazy var titleTextField : UITextField = {
        let label = UITextField()
        label.text = ""
        label.font = .boldSystemFont(ofSize: 25.0)
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    private lazy var dateLabel : UILabel = {
        let label = UILabel()
        label.text = "Изменено: "
        label.textAlignment = .right
        label.backgroundColor = .white
        label.textColor = .systemGray
        label.font = .systemFont(ofSize: 13, weight: .medium)
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    private lazy var addImageBarItem = UIBarButtonItem(
        image: UIImage(systemName: "camera"),
        style: .plain,
        target: self,
        action: #selector(addPhotoFromLibrary)
    )
    
    private lazy var endEditingBarItem = UIBarButtonItem(
        title: "Готово",
        style: .plain,
        target: self,
        action: #selector(hideKeyboard)
    )
    
    // MARK: - Initializers
    
    init(presenter: INoteEditingPresenter) {
        self.presenter = presenter
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    // MARK: - Lifecycle
    
    override func viewDidLoad() {
        let tapGesture = UITapGestureRecognizer(target: view, action: #selector(UIView.endEditing))
        view.addGestureRecognizer(tapGesture)
        super.viewDidLoad()
        setupUI()
        presenter.viewDidLoad()
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        presenter.userWillCloseNoteEditingScreen(
            title: titleTextField.text ?? "",
            text: textView.attributedText,
            date: Date()
        )
    }
    
    // MARK: - Private
    
    @objc private func hideKeyboard() {
        view.endEditing(true)
        presenter.userWillCloseNoteEditingScreen(
            title: titleTextField.text ?? "",
            text: textView.attributedText,
            date: Date()
        )
    }
    
    @objc private func addPhotoFromLibrary() {
        
        let vc = UIImagePickerController()
        vc.sourceType = .photoLibrary
        vc.delegate = self
        vc.allowsEditing = true
        present(vc, animated: true)
    }
    
    @objc private func keyboardWillDisappear(notification: NSNotification) {
        navigationItem.rightBarButtonItem = nil
        let contentInsets = UIEdgeInsets.zero
        self.textView.contentInset = contentInsets
        self.textView.verticalScrollIndicatorInsets = contentInsets
    }
    
    @objc private func kyeboardWillAppear(notification: NSNotification) {
        
        let info = notification.userInfo!
        var value = (info[UIResponder.keyboardFrameEndUserInfoKey] as! NSValue).cgRectValue
        value = self.textView.convert(value, from:nil)
        self.textView.contentInset.bottom = value.size.height
        self.textView.verticalScrollIndicatorInsets.bottom = value.size.height
        navigationItem.rightBarButtonItem = endEditingBarItem
        
    }
    private func setupUI() {
        NotificationCenter.default.addObserver(self, selector: #selector(kyeboardWillAppear), name: UIResponder.keyboardWillShowNotification, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillDisappear), name: UIResponder.keyboardWillHideNotification, object: nil)
        let bottom = textView.contentSize.height
        let bar = UIToolbar()
        bar.backgroundColor = .systemGray
        bar.items = [addImageBarItem]
        bar.sizeToFit()

        textView.inputAccessoryView = bar
        dateLabel.backgroundColor = .systemBackground
        titleTextField.backgroundColor = .systemBackground
        addImageBarItem.tintColor = .customColor
        textView.textColor = .label
        textView.setContentOffset(CGPoint(x: 0, y: bottom), animated: true)

        navigationController!.navigationBar.barTintColor = .systemBackground
        view.backgroundColor = .systemBackground

        view.addSubview(dateLabel)
        view.addSubview(titleTextField)
        view.addSubview(textView)
        
        textView.setContentHuggingPriority(.defaultHigh , for: .vertical)
        textView.setContentCompressionResistancePriority(.defaultHigh , for: .vertical)
        
        titleTextField.setContentHuggingPriority(.defaultLow , for: .vertical)
        titleTextField.setContentCompressionResistancePriority(.defaultLow , for: .vertical)
        
        NSLayoutConstraint.activate([
            titleTextField.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 8),
            titleTextField.topAnchor.constraint(equalTo: dateLabel.bottomAnchor,constant: 0),
            titleTextField.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            titleTextField.bottomAnchor.constraint(equalTo: textView.topAnchor),
            textView.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 8),
            textView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            textView.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor, constant: -8),
            dateLabel.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            dateLabel.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor,constant: 8),
        ])
    }
}

// MARK: - INoteEditingViewController

extension NoteEditingViewController: INoteEditingViewController {
    func configure(with model: NoteEditingViewModel) {
        if model.title.isEmpty {
            titleTextField.becomeFirstResponder()
        } else {
            textView.becomeFirstResponder()
        }
        textView.attributedText = model.text
        titleTextField.text = model.title
        dateLabel.text = model.date
    }
    
    func showAlert(with error: Error) {
        print("Error") //TODO
    }
    
    func close() {
        navigationController?.popViewController(animated: true)
    }
}

extension NoteEditingViewController : UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        let image1Attachment = NSTextAttachment()
        if let image = info[UIImagePickerController.InfoKey(rawValue: "UIImagePickerControllerEditedImage")] as? UIImage {
            let resizedImage = image.resized(to: CGSize(width: UIScreen.main.bounds.width/1.5, height: UIScreen.main.bounds.width/1.5))
            image1Attachment.image = resizedImage
            let oldText = textView.attributedText!
            let result = NSMutableAttributedString()
            result.append(oldText)
            result.append(NSAttributedString(attachment: image1Attachment))
            textView.attributedText =  result
        }
        picker.dismiss(animated: true, completion: nil)
    }
    
    func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
        picker.dismiss(animated: true, completion: nil)
    }
}

extension UIImage {

    func resized(to size: CGSize) -> UIImage {
        return UIGraphicsImageRenderer(size: size).image { _ in
            draw(in: CGRect(origin: .zero, size: size))
        }
    }
}

extension NoteEditingViewController {

    func hideKeyboardWhenTappedAround() {
        let tapGesture = UITapGestureRecognizer(target: self,
                                                action: #selector(hideKeyboard))
        view.addGestureRecognizer(tapGesture)
    }
}
