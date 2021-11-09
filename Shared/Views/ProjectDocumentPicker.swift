//
//  ProjectDocumentPicker.swift
//  SwiftUIDocumentsDemo (iOS)
//
//  Created by Mahesh sai on 07/09/21.
//

import SwiftUI

struct ProjectDocumentPicker: UIViewControllerRepresentable {
    @ObservedObject var reportsViewModel: ProjectReportViewModel
    @Binding var added: Bool
    @Binding var iniCloud: Bool
    func makeUIViewController(context: Context) -> some UIViewController {
        let controller = UIDocumentPickerViewController(forOpeningContentTypes: [.text,.pdf])
        controller.allowsMultipleSelection = false
        controller.shouldShowFileExtensions = true
        controller.delegate = context.coordinator
        return controller
    }
    func updateUIViewController(_ uiViewController: UIViewControllerType, context: Context) {
        
    }
    func makeCoordinator() -> DocumentPickerCoordinator {
        DocumentPickerCoordinator(projectVM: reportsViewModel, added: $added, iniCloud: $iniCloud)
    }
    
}
class DocumentPickerCoordinator: NSObject, UIDocumentPickerDelegate {
    @ObservedObject var reportsViewModel: ProjectReportViewModel
    @Binding var added: Bool
    @Binding var iniCloud: Bool

    init(projectVM: ProjectReportViewModel, added: Binding<Bool>, iniCloud: Binding<Bool> ) {
        reportsViewModel = projectVM
        self._added = added
        self._iniCloud = iniCloud

    }
    
    func documentPicker(_ controller: UIDocumentPickerViewController, didPickDocumentsAt urls: [URL]) {
        guard let url = urls.first else {
            return
        }
        reportsViewModel.addURLS(pickedURL: url, storeInIcloud: iniCloud)
        added = true
    }
    
}


//struct ProjectDocumentPicker_Previews: PreviewProvider {
//    static var previews: some View {
//        ProjectDocumentPicker()
//    }
//}
