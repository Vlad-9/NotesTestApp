//
//  Note.swift
//  testApplcation
//
//  Created by Влад on 20.03.2022.
//

import Foundation

struct Note {
    var id: String
    var text: NSAttributedString?
    var date: Date
    var pinned: Bool
    var title: String?

    init (dbNote: DBNote) {
        id = dbNote.id
        text = dbNote.text
        date = dbNote.date
        pinned = dbNote.pinned
        title = dbNote.title
    }
}
