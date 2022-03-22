//
//  NotesStorage.swift
//  testApplcation
//
//  Created by Влад on 20.03.2022.
//

import UIKit
import CoreData

enum NotesStorageError: Error {
    case conntextIsMissing
}

protocol INotesStorage {
    func fetchNotes() throws -> [Note]
    func createBlankNote() throws -> Note
    func delete(_ note: Note) throws
    func update(_ note: Note) throws
    func pin (_ note: Note) throws
}

final class NotesStorage: INotesStorage {

    // MARK: - Properties

    private var dbnotes: [DBNote] = []
    private lazy var viewContext: NSManagedObjectContext? = {
        guard let appDelegate = UIApplication.shared.delegate as? AppDelegate else { return nil }
        let persistentContainer = appDelegate.persistentContainer
        return persistentContainer.viewContext
    }()

    // MARK: - INotesStorage

    func fetchNotes() throws -> [Note] {
        guard let context = viewContext else { throw NotesStorageError.conntextIsMissing }
        let request  = NSFetchRequest<NSFetchRequestResult>(entityName: "DBNote")

            if let results = try context.fetch(request) as? [DBNote]  { 
                dbnotes = results
                return  results.map { dbNote in
                    Note(dbNote: dbNote)
                }
            }

        return []
    }
     func createBlankNote() throws -> Note {
         guard let context = viewContext else { throw NotesStorageError.conntextIsMissing }
         let blankNote = DBNote(context: context)
         blankNote.title = ""
         blankNote.text = NSAttributedString(string:"")
         blankNote.pinned = false
         blankNote.id = UUID().uuidString
         blankNote.date = Date()
         try context.save()
         dbnotes.append(blankNote)

        return Note(dbNote: blankNote)
    }

    func update(_ note: Note) throws {

        guard let context = viewContext else { throw NotesStorageError.conntextIsMissing }
        let noteFromDB = dbnotes.first(where: { $0.id == note.id })
        noteFromDB?.text = note.text
        noteFromDB?.title = note.title
        noteFromDB?.date = note.date
        noteFromDB?.pinned = note.pinned
        
        try context.save()
    }
    func pin(_ note: Note) throws {

        guard let context = viewContext else { throw NotesStorageError.conntextIsMissing }
        let noteFromDB = dbnotes.first(where: { $0.id == note.id })
        
        noteFromDB?.pinned = note.pinned
        try context.save()
    
    }

    func delete(_ note: Note) throws {
        guard let context = viewContext else { throw NotesStorageError.conntextIsMissing }
        guard let noteFromDB = dbnotes.first(where: { $0.id == note.id }) else { return } 
        dbnotes.removeAll(where: { $0.id == note.id })

        context.delete(noteFromDB)
        try context.save()
    }
}
