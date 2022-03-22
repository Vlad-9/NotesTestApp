//
//  DBNote+CoreDataProperties.swift
//  testApplcation
//
//  Created by Влад on 20.03.2022.
//
//

import Foundation
import CoreData


extension DBNote {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<DBNote> {
        return NSFetchRequest<DBNote>(entityName: "DBNote")
    }

    @NSManaged public var id: String
    @NSManaged public var text: NSAttributedString?
    @NSManaged public var date: Date
    @NSManaged public var pinned: Bool
    @NSManaged public var title: String?

}

extension DBNote : Identifiable {

}
