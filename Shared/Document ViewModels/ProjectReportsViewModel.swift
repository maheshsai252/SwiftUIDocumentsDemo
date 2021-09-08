//
//  ProjectReportsViewModel.swift
//  SwiftUIDocumentsDemo (iOS)
//
//  Created by Mahesh sai on 07/09/21.
//

import Foundation
import Combine

class ProjectReportViewModel: ObservableObject {
    let project: Project //Current Project
    @Published var downloading = false //Downloading indicator if doc is stored in icloud
    @Published var selectedUrl: URL? //URL of selected Document to view
    @Published var documents: [TrackerDocument] = [] // list of documents inside project
    private var ich = iCloudHandler()
    private var ldh = LocalDocHandler()
    @Published var progressing = false // Indicates document is being added
    @Published var showStatus: Bool = false
    @Published var status: String = "Trouble in adding the file right now" //Status of adding file
    private let docCDHandler = TrackerDocumentCoreDataHandler()
    init(project: Project) {
        self.project = project
        self.documents = docCDHandler.listOfTrackerDocuments(in: project)
        self.documents = documents.sorted(by: {($0.name ?? "") < ($1.name ?? "")})
        DispatchQueue.global(qos: .userInitiated).async {[self] in
            if isICloudContainerAvailable() == true {
                ich.startupActivities(project: project.name ?? "project")
                ldh.startupActivities(project: project.name ?? "project")
            } else {
                ldh.startupActivities(project: project.name ?? "project")
            }
        }
    }
    /// Checks if iCloud account is setup
    /// - Returns: true if setup is done
    func isICloudContainerAvailable() -> Bool {
        if FileManager.default.ubiquityIdentityToken != nil {
            return true
        } else {
            return false
        }
    }
    /// Gives the URL of selected Document if present in Local or download the document from iCloud
    /// - Parameter doc: selected Document
    /// - Returns: URL of Document
    func generateUrl(of doc: TrackerDocument) -> URL? {
        
        if (URL(string: doc.url ?? "")?.fileExists() ?? false) {
            return URL(string: doc.url ?? "")
        }
        if doc.location == "Cloud" {
            let url = ich.giveURL(project: project.name ?? "project", file: doc.name ?? "file")
           downloadFromCloud(url: url)
           return url
        } else {
            let url =  ldh.giveURL(project: project.name ?? "project", file: doc.name ?? "file")
             if url?.fileExists() ?? false {
                 return url
             }
             status = "Document does not belong to this device"
             showStatus = true
             return nil
        }
    }
    
    /// Start and monitor download of document from iCloud
    /// - Parameter url: iCloud URL
    func downloadFromCloud(url: URL?) {
        do {
            if let url = url, (url.fileExists() == false && downloading == false) {
                    try FileManager.default.startDownloadingUbiquitousItem(at: url)
                    downloading = true
                    DispatchQueue.global(qos: .background).async {
                        var t = url.fileExists()
                        while t == false {
                            t = url.fileExists()
                        }
                        DispatchQueue.main.async {
                            self.downloading = false
                        }
                    }
            }
        } catch  {
            print(error)
        }
    }
    /// Copies the document to local or iCloud based on user preference
    /// - Parameters:
    ///   - pickedURL: picked document URL
    ///   - storeInIcloud: indiacte document storage location
    func addURLS(pickedURL: URL, storeInIcloud: Bool ) {
//        let cloudAvailable = false // Use Your Own 
       
        DispatchQueue.global(qos: .userInteractive).async {[self] in
            DispatchQueue.main.async {
                progressing = true
            }
            var res: URL?
            ///check icloud storage availability
            if storeInIcloud {
                if isICloudContainerAvailable() == true {
                    print("cloud available")
                    res = ich.copyDocumentsToiCloudDirectory(localDocumentsURL: pickedURL, project: project.name ?? "")
                } else {
                    print("cloud not available")
                    DispatchQueue.main.async {
                        self.status = "Trouble With iCloud Account\nChange Storage option to Local "
                        self.showStatus = true
                    }
                }
            } else {
                res = ldh.copyDocumentsToLocalDirectory(pickedURL: pickedURL, project: project.name ?? "project")
            }
            
            if res == nil {
                DispatchQueue.main.async {
                    if showStatus != true {
                        status = "Unable to add the file right now"
                        self.showStatus = true
                    }
                }
            } else {
                DispatchQueue.main.async {
                    let storage =  storeInIcloud ? "Cloud" : "Local"
                    if let i = self.documents.firstIndex(where: {$0.name == res?.lastPathComponent}) {
                        documents[i].size = res?.byteCount(size: Double(res?.fileSize ?? 0))
                        status = "File Replaced Successfully With Latest Version into \(storage) storage"
                    } else {
                        let doc = docCDHandler.addTrackerDocument(title: res?.lastPathComponent ?? "", location: storage, url: res?.absoluteString ?? "", size: res?.byteCount(size: Double(res?.fileSize ?? 0)) ?? "Zero KB", to: project)
                        if let doc = doc {
                            self.documents.append(doc)
                            docCDHandler.save()
                            status = "File Added Successfully into \(storage) storage"
                        }
                    }
                    showStatus = true
                }
            }
            DispatchQueue.main.async {
                self.progressing = false
            }
        }
    }
    
    /// Remove Documents if present in local of device or icloud
    /// - Parameter index: index of documents
    func removeUrls(from index: IndexSet) {
        for i in index {
            
            if let url = self.generateUrl(of: documents[i]) {
                if documents[i].location == "Local" && !url.fileExists() {
                    status = "File does not belong to this device\nOperation Not Permitted"
                    showStatus = true
                    return
                }
                print(url)
                if downloading == true {
                    status = "File Download is in Progress\n Please try after some time"
                    showStatus = true
                    return
                }
                DispatchQueue.global(qos: .utility).async { [self] in
                    if isICloudContainerAvailable() == false {
                        ldh.removeUsingUrl(localURL: url)
                    } else {
                        ich.removeUsingUrl(icloudUrl: url)
                    }
                }
                DispatchQueue.main.async { [self] in
                    docCDHandler.deleteTrackerDocument(doc: documents[i])
                    documents.remove(at: i)
                    docCDHandler.save()
                }
            }
        }
    }
}

//.appendingPathComponent(subfolder,isDirectory: true)
extension URL {
    func fileExists() -> Bool {
        let p = self.path.replacingOccurrences(of: "file://", with: "")
        return FileManager.default.fileExists(atPath: p)
        
    }
}
