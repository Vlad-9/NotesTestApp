//
//  NoteEditingPresenter.swift
//  testApplcation
//
//  Created by Влад on 19.03.2022.
//

import Foundation

protocol INoteEditingPresenter {
    var note: Note { get }
    func viewDidLoad()
    func userDidTapBackButton()
    func userWillCloseNoteEditingScreen(
        title: String,
        text: NSAttributedString,
        date: Date
    )
}

final class NoteEditingPresenter {
    
    // MARK: - Dependencies
    
    private(set) var note: Note
    var onClose: ((_ updatedNote: Note) -> Void)?
    weak var view: INoteEditingViewController?
    
    // MARK: - Initializers
    
    init(note: Note) {
        self.note = note
    }
}

// MARK: - INoteEditingPresenter

extension NoteEditingPresenter: INoteEditingPresenter {
    func viewDidLoad() {
        let dateFormatter = DateFormatter()
        dateFormatter.locale =  Locale(identifier: "ru_RU")
        dateFormatter.dateFormat = "dd MMMM yyyy г. в HH:mm"
        
        let date = dateFormatter.string(from: note.date)
        let viewModel = NoteEditingViewModel(
            title: note.title ?? "",
            text: note.text ?? NSAttributedString(string: ""),
            date: date
        )
        view?.configure(with: viewModel)
    }
    
    func userDidTapBackButton() {
        view?.close()
    }
    
    func userWillCloseNoteEditingScreen(title: String, text: NSAttributedString, date: Date) {
        note.title = title
        note.text =  text
        note.date = date
        onClose?(note)
    }
}
