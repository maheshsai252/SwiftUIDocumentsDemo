//
//  ProjectsListView.swift
//  SwiftUIDocumentsDemo (iOS)
//
//  Created by Mahesh sai on 07/09/21.
//

import SwiftUI

struct ProjectsListView: View {
    @Environment(\.managedObjectContext) private var viewContext
    @FetchRequest(
        sortDescriptors: [NSSortDescriptor(keyPath: \Project.name, ascending: true)],
        animation: .default)
    private var projects: FetchedResults<Project>
    @State var addItem = false
    var body: some View {
        List {
            ForEach(projects) { item in
                NavigationLink(destination: ProjectDocumentListView(reportsVM: ProjectReportViewModel(project: item))) {
                    Text("\(item.name ?? "")")
                }
                
            }
        }
        .sheet(isPresented: $addItem, content: {
            AddProjectView()
        })
        .toolbar {
            ToolbarItem(placement: .principal) {
                Text("Projects").bold()
            }
            ToolbarItem(placement: .navigationBarTrailing) {
                Button(action: add) {
                    Label("Add Item", systemImage: "plus")
                }
            }
            
        }
    }
    private func add() {
        withAnimation {
            addItem = true
        }
    }
}

struct ProjectsListView_Previews: PreviewProvider {
    static var previews: some View {
        ProjectsListView()
    }
}
