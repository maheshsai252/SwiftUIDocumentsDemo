//
//  AddProjectView.swift
//  SwiftUIDocumentsDemo (iOS)
//
//  Created by Mahesh sai on 07/09/21.
//

import SwiftUI

struct AddProjectView: View {
    @Environment(\.managedObjectContext) private var viewContext
    @State var name: String = ""
    var body: some View {
        Form {
            TextField("Project Name", text: $name)
            Button {
                addItem()
            } label: {
                Text("add")
            }

        }
    }
    private func addItem() {
        withAnimation {
            let newItem = Project(context: viewContext)
            newItem.name = name

            do {
                try viewContext.save()
            } catch {
                let nsError = error as NSError
                fatalError("Unresolved error \(nsError), \(nsError.userInfo)")
            }
        }
    }
}

struct AddProjectView_Previews: PreviewProvider {
    static var previews: some View {
        AddProjectView()
    }
}
