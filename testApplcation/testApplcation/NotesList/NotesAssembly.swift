//
//  NotesAssembly.swift
//  testApplcation
//
//  Created by Влад on 20.03.2022.
//

import Foundation
import UIKit

protocol INotesAssembly {
    func createNoteViewController(notesStorage: INotesStorage) -> UIViewController
}

final class NotesAssembly: INotesAssembly {
    func createNoteViewController(notesStorage: INotesStorage) -> UIViewController {
        let presenter = NotesPresenter(notesStorage: notesStorage)
        let view = NotesViewController(presenter: presenter)
        presenter.view = view
        return view
    }
}

