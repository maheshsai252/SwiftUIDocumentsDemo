//
//  SwiftUIDocumentsDemoApp.swift
//  Shared
//
//  Created by Mahesh sai on 07/09/21.
//

import SwiftUI

@main
struct SwiftUIDocumentsDemoApp: App {
    let persistenceController = PersistenceController.shared

    var body: some Scene {
        WindowGroup {
            NavigationView {
            ProjectsListView()
                .environment(\.managedObjectContext, persistenceController.container.viewContext)
            }
        }
    }
}
