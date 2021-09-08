//
//  ProjectDocumentListView.swift
//  SwiftUIDocumentsDemo (iOS)
//
//  Created by Mahesh sai on 07/09/21.
//

import SwiftUI

struct ProjectDocumentListView: View {
    @StateObject var reportsVM: ProjectReportViewModel
    @State var add = false
    @State var open = false
    @State var added = false
    @State var inCloud = false
    var body: some View {
        VStack {
            Toggle("Store in iCloud", isOn: $inCloud)
            ZStack {
                List {
                    ForEach(reportsVM.documents, id: \.id) {(doc) in
                        Button(action: {
                            open = true
                            reportsVM.selectedUrl = reportsVM.generateUrl(of: doc)
//                            open = true
                        }, label: {
                            DocumentCell(doc: doc)
                        })
                    }.onDelete { index in
                        reportsVM.removeUrls(from: index)
                    }
                }
                if reportsVM.progressing == true {
                    ProgressView()
                }
            }
                .fullScreenCover(isPresented: $open, content: {
                    ProjectDocumentOpener(reportsViewModel: reportsVM, open: $open)
                })

        }
        .alert(isPresented: $reportsVM.showStatus, content: {
            Alert(title: Text(reportsVM.status).foregroundColor(.red).bold(), message: nil, dismissButton: .default(Text("Ok")))
        })
        
        .sheet(isPresented: $add, content: {
            #if !os(macOS)
            ProjectDocumentPicker(reportsViewModel: reportsVM, added: $added, iniCloud: $inCloud)
            #endif
        })
        .toolbar {
            ToolbarItem(placement: .principal) {
                Text("Documents")
                    .bold()
            }
            #if !os(macOS)
            ToolbarItem(placement: .navigationBarTrailing) {
                Button {
                    add = true
                } label: {
                    Image(systemName: "doc.badge.plus")
                }
            }
            #endif
        }

    }
}



struct DocumentCell: View {
    let doc: TrackerDocument
    var shortFormatter: DateFormatter {
        let f = DateFormatter()
        f.timeZone = TimeZone(secondsFromGMT: 0) ?? .current
        f.dateStyle = .short
        f.timeStyle = .none
        return f
    }
    var body: some View {
        HStack(alignment: .center, spacing: 15) {
            Image(systemName: "doc.circle")
                .resizable()
                .frame(width: 35, height: 35)
            VStack(alignment: .leading) {
                Text(doc.name ?? "")
                    .bold()
                HStack {
                    Text("\(doc.size ?? "Zero KB")")
                        .padding(2)
                        .border(Color.green)
                    Text("\(shortFormatter.string(from: doc.date ?? Date()))")
                        .padding(2)
                        .border(Color.yellow)

                }
            }
        }.padding(5)
    }
}
