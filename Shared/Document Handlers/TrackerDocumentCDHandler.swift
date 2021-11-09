//
//  TrackerDocumentCDHandler.swift
//  SwiftUIDocumentsDemo (iOS)
//
//  Created by Mahesh sai on 07/09/21.
//

import Foundation

import CoreData

struct TrackerDocumentCoreDataHandler {
    var context = PersistenceController.shared.container.viewContext
    func addTrackerDocument(title: String, location: String, url: String, size: String, to project: Project) -> TrackerDocument? {
        if(!title.isEmpty) {
            let docToBeAdded = TrackerDocument(context: context)
            docToBeAdded.name = title
            docToBeAdded.location = location
            docToBeAdded.url = url
            docToBeAdded.date = Date()
            docToBeAdded.size = size
            project.addToDocuments(docToBeAdded)
            save()
            return docToBeAdded
        }
        return nil
    }
    
    func listOfTrackerDocuments() -> [TrackerDocument] {
        let fetchRequest = NSFetchRequest<NSFetchRequestResult>(entityName: "TrackerDocument")
        var items = [TrackerDocument]()
        do {
            items = try context.fetch(fetchRequest) as! [TrackerDocument]
        }
        catch {
            print(error)
        }
        return items
    }
    func listOfTrackerDocuments(in project: Project) -> [TrackerDocument] {
        let items: [TrackerDocument] = project.documents?.allObjects as? [TrackerDocument] ?? []
        return items
    }
   
    
//    func reloadBug(name: String) -> Bug {
//        let fr: NSFetchRequest = Bug.fetchRequest()
//        let predicate: NSPredicate = NSPredicate(format: "title == %@", name)
//        fr.predicate = predicate
//        var items = [Bug]()
//        do {
//            items = try context.fetch(fr)
//        } catch {
//
//        }
//        return items[0]
//    }
    func deleteTrackerDocument(doc: TrackerDocument) {
        context.delete(doc)
        save()
    }
    func save() {
        if context.hasChanges {
            
            do {
                try context.save()
            }
            catch {
                print(error)
            }
        }
    }
}
