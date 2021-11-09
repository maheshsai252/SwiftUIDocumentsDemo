//
//  ProjectDocumentOpener.swift
//  SwiftUIDocumentsDemo (iOS)
//
//  Created by Mahesh sai on 07/09/21.
//

import SwiftUI
import QuickLook

struct PreviewController: UIViewControllerRepresentable {
    let url: URL
    var error: Binding<Bool>
    func makeUIViewController(context: Context) -> QLPreviewController {
        let controller = QLPreviewController()
        controller.dataSource = context.coordinator
        controller.isEditing = false
        return controller
    }
    
    func makeCoordinator() -> Coordinator {
        return Coordinator(parent: self)
    }
    
    func updateUIViewController(
        _ uiViewController: QLPreviewController, context: Context) {}
    
    class Coordinator: QLPreviewControllerDataSource {
        var parent: PreviewController
        
        init(parent: PreviewController) {
            self.parent = parent
        }
        
        func numberOfPreviewItems(
            in controller: QLPreviewController
        ) -> Int {
            return 1
        }
        
        func previewController(
            _ controller: QLPreviewController, previewItemAt index: Int
        ) -> QLPreviewItem {
            
            guard self.parent.url.startAccessingSecurityScopedResource()
            else {
                return NSURL(fileURLWithPath: parent.url.path)
            }
            defer {
                self.parent.url.stopAccessingSecurityScopedResource()
            }
            
            return NSURL(fileURLWithPath: self.parent.url.path)
        }
        
    }
}

struct ProjectDocumentOpener: View {
    @ObservedObject var reportsViewModel: ProjectReportViewModel
    @Binding var open: Bool
    @State var errorInAccess = false
    var body: some View {
        NavigationView {
                VStack(alignment: .center, spacing: 0) {
                    if let url = reportsViewModel.selectedUrl {
                        if reportsViewModel.downloading == false {
                            PreviewController(url: url, error: $errorInAccess)
                        } else {
                            ProgressView("Downloading")
                        }

                    } else {
                        ProgressView("Loading")
                    }
                }
            .navigationBarTitleDisplayMode(.inline)
            .navigationBarTitle(                    Text(reportsViewModel.selectedUrl?.lastPathComponent ?? "")
            )
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("Done") {
                        self.open = false
                    }
                }
            }
        }
    }
}
