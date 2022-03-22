//
//  NotesPresenter.swift
//  testApplcation
//
//  Created by Влад on 20.03.2022.
//


import UIKit
import CoreData

protocol INotesPresenter {

    var notes: [Note] { get }
    var pinnedNotes: [Note] { get }

    func viewDidLoad()
    func userDidRequestCreate()
    func userDidSelect(_ note: Note)
    func userDidUpdate(_ note: Note)
    func userDidDelete(_ note: Note)
    func userDidPin(_ note: Note)
    func getImage(atSring: NSAttributedString) -> UIImage?

}

final class NotesPresenter {

    // MARK: - Dependencies

    private let notesStorage: INotesStorage
    weak var view: INotesViewController?

    // MARK: - Properties

    private(set) var notes: [Note] = []
    private(set) var pinnedNotes: [Note] = []

    // MARK: - Initializers

    init(notesStorage: INotesStorage) {
        self.notesStorage = notesStorage
    }
    // MARK: - Private

    private func filterNotes(note: [Note]) {
        let filtered = note.filter { note in
            return note.pinned == false
        }

        pinnedNotes = filtered
    }
    // MARK: - Lifecycle

    func viewDidLoad() {
        notes = (try? notesStorage.fetchNotes()) ?? []
        view?.update(notes)
    }
}

// MARK: - INotesPresenter

extension NotesPresenter: INotesPresenter {
    func userDidRequestCreate() {
        do {
            let note = try notesStorage.createBlankNote()
            view?.openNoteEditingScreen(with: note)
        } catch {
            view?.showAlert(with: error)
        }
    }

    func userDidSelect(_ note: Note) {
        view?.openNoteEditingScreen(with: note)
    }

    func userDidUpdate(_ note: Note) {
        do {
            try notesStorage.update(note)

            view?.update(notes)
            
        } catch {
            view?.showAlert(with: error)
        }
    }

    func userDidDelete(_ note: Note) {
        do {
            try notesStorage.delete(note)

            notes.removeAll(where: { $0.id == note.id })
            view?.update(notes)

        } catch {
            view?.showAlert(with: error)
        }
    }

    func userDidPin(_ note: Note) {
        do {

            if let index = notes.firstIndex(where: { $0.id == note.id }) {

                notes[index].pinned = !notes[index].pinned 
                try notesStorage.update(notes[index])
            }

        } catch {
            view?.showAlert(with: error)
        }
        view?.update(notes)
    }
    
    func getImage(atSring: NSAttributedString) -> UIImage? {
      var imagesArray = [Any]()

      atSring.enumerateAttribute(
        NSAttributedString.Key.attachment, in: NSRange(location: 0, length: atSring.length),
        options: [],
        using: { (value, range, stop) -> Void in
          if value is NSTextAttachment {
            let attachment: NSTextAttachment? = (value as? NSTextAttachment)
            var image: UIImage? = nil

            if (attachment?.image) != nil {
              image = attachment?.image
            } else {
              image = attachment?.image(
                forBounds: (attachment?.bounds)!, textContainer: nil, characterIndex: range.location)
            }

            if image != nil {
              imagesArray.append(image!)
            }
          }
        })

      return imagesArray.first as? UIImage
    }
}
