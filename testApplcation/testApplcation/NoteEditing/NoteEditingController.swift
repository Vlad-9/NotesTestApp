//
//  NoteViewController.swift
//  testApplcation
//
//  Created by Влад on 18.03.2022.
//

import UIKit
import CoreData

// MARK: - Model

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
    private lazy var increaseFontSizeBarItem = UIBarButtonItem(
        image: UIImage(systemName: "plus.circle"),
        style: .plain,
        target: self,
        action: #selector(increaseSelectedFontSize)
    )
    private lazy var changeFontNameBarItem = UIBarButtonItem(
        image: UIImage(systemName: "textformat.abc"),
        style: .plain,
        target: self,
        action: #selector(changeSelectedTextFont)
    )

    private lazy var decreaseFontSizeBarItem = UIBarButtonItem(
        image: UIImage(systemName: "minus.circle"),
        style: .plain,
        target: self,
        action: #selector(decreaseSelectedFontSize)
    )

    private lazy var changeTextAlignmentBarItem = UIBarButtonItem(
        image: UIImage(systemName: "text.justify"),
        style: .plain,
        target: self,
        action: #selector(changeTextAlignment)
    )

    private lazy var changeTextColorBarItem = UIBarButtonItem(
        image: UIImage(systemName: "paintbrush.pointed"),
        style: .plain,
        target: self,
        action: #selector(changeSelectedTextColor)
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

    @objc private func changeTextAlignment() {
        switch  textView.textAlignment {
        case .left:
            textView.textAlignment = .center

        case .right:
            textView.textAlignment = .left

        default:
            textView.textAlignment = .right
        }
    }

    @objc private func changeSelectedTextFont() {
        let selectedText = textView.selectedRange
        textView.attributedText.enumerateAttribute(.font, in: selectedText) { (value, range, stop) in
            if let oldFontName = value as? UIFont {

                var newFontName = ""
                switch oldFontName.fontName {
                case "Helvetica":
                    newFontName = "TimesNewRomanPSMT"
                case "TimesNewRomanPSMT":
                    newFontName = "CourierNewPSMT"
                case "CourierNewPSMT":
                    newFontName = "AmericanTypewriter"
                case "AmericanTypewriter":
                    newFontName = "Georgia"
                case "Georgia":
                    newFontName = "Helvetica"
                default:
                    newFontName = "Helvetica"
                }
                let myAttribute = [  NSAttributedString.Key.font: UIFont (name: newFontName, size: oldFontName.pointSize)]
                textView.textStorage.addAttributes(myAttribute, range: selectedText)
            }
        }
    }

    @objc private func changeSelectedTextColor() {
        let selectedText = textView.selectedRange
        var newColor = UIColor.systemRed

        textView.attributedText.enumerateAttribute(.foregroundColor, in: selectedText) { (value, range, stop) in

            if let oldColor = value as? UIColor
            {
                switch oldColor {
                case .label:
                    newColor = .systemRed
                case .systemRed:
                    newColor = .systemGreen
                case .systemGreen:
                    newColor = .customColor
                case .customColor:
                    newColor = .systemBlue
                case .systemBlue:
                    newColor = .systemGray2
                case .systemGray2:
                    newColor = .label
                default:
                    newColor = .systemRed
                }
            }
            let myAttribute = [  NSAttributedString.Key.foregroundColor: newColor]
            textView.textStorage.addAttributes(myAttribute, range: selectedText)
        }
    }

    @objc private func decreaseSelectedFontSize() {
        let selectedText = textView.selectedRange
        textView.attributedText.enumerateAttribute(.font, in: selectedText) { (value, range, stop) in
            if let oldFont = value as? UIFont {
                let myAttribute = [  NSAttributedString.Key.font: oldFont.withSize(oldFont.pointSize-1)]
                textView.textStorage.addAttributes(myAttribute, range: selectedText)
            }
        }
    }

    @objc private func increaseSelectedFontSize() {
        let selectedText = textView.selectedRange
        textView.attributedText.enumerateAttribute(.font, in: selectedText) { (value, range, stop) in
            if let oldFont = value as? UIFont {

                let myAttribute = [  NSAttributedString.Key.font:  oldFont.withSize(oldFont.pointSize+1)]
                textView.textStorage.addAttributes(myAttribute, range: selectedText)
            }
        }
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
        let flexibleSpace = UIBarButtonItem(barButtonSystemItem: UIBarButtonItem.SystemItem.flexibleSpace, target: nil, action: nil);
        bar.backgroundColor = .systemGray
        bar.items = [increaseFontSizeBarItem,decreaseFontSizeBarItem,changeTextAlignmentBarItem,changeFontNameBarItem,changeTextColorBarItem,flexibleSpace,addImageBarItem]
        bar.sizeToFit()

        textView.inputAccessoryView = bar
        dateLabel.backgroundColor = .systemBackground
        titleTextField.backgroundColor = .systemBackground
        addImageBarItem.tintColor = .customColor
        changeFontNameBarItem.tintColor = .customColor
        increaseFontSizeBarItem.tintColor = .customColor
        decreaseFontSizeBarItem.tintColor = .customColor
        changeTextAlignmentBarItem.tintColor = .customColor
        changeTextColorBarItem.tintColor = .customColor
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
            textView.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -8),
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
        let alert = UIAlertController(title: "Ошибка", message: error.localizedDescription , preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "Закрыть", style: UIAlertAction.Style.default, handler: nil))
        self.present(alert, animated: true, completion: nil)
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
