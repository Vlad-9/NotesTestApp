//
//  NoteEditingAssembly.swift
//  testApplcation
//
//  Created by Влад on 19.03.2022.
//

import UIKit

protocol INoteEditingAssembly {
    func createNoteEditingViewController(
        note: Note,
        onEditingFinish: @escaping (_ updatedNote: Note) -> Void
    ) -> UIViewController
}

final class NoteEditingAssembly: INoteEditingAssembly {

    func createNoteEditingViewController(
        note: Note,
        onEditingFinish: @escaping (_ updatedNote: Note) -> Void
    ) -> UIViewController {
        let presenter = NoteEditingPresenter(note: note)
        let view = NoteEditingViewController(presenter: presenter)
        presenter.view = view
        presenter.onClose = onEditingFinish
        return view
    }
}
