//
//  LocalHandler.swift
//  SwiftUIDocumentsDemo (iOS)
//
//  Created by Mahesh sai on 07/09/21.
//
import Foundation
import UIKit

struct LocalDocHandler {
    var subfolder: String
    var rootUrl: URL?
    init() {
        subfolder =  "Projects"
        do {
            if let fileManagerUrl = FileManager.default.containerURL(forSecurityApplicationGroupIdentifier: "group.com.maheshsai.walker") {
                rootUrl = fileManagerUrl
            } else {
                rootUrl = try FileManager.default.url(for: .documentDirectory, in: .userDomainMask, appropriateFor: nil, create: true)
            }
        } catch  {
            print(error)
        }
    }
    
    /// Return the URL of a document
    /// - Parameters:
    ///   - project: name of project
    ///   - file: name of file
    /// - Returns: URL of file
    func giveURL(project: String, file: String) -> URL? {
        guard var iCloudDocumentsURL =
                rootUrl?.appendingPathComponent(subfolder, isDirectory: true)
                .appendingPathComponent(project, isDirectory: true) else {
            return nil
        }
        iCloudDocumentsURL = iCloudDocumentsURL.appendingPathComponent(file , isDirectory: false)
        return iCloudDocumentsURL
    }
    
    /// Copy the document at pickedURL to localURL
    /// - Parameters:
    ///   - pickedURL: URL of picked document
    ///   - project: project name
    /// - Returns: Local URL of document
    func copyDocumentsToLocalDirectory(pickedURL: URL, project: String) -> URL? {
        guard let url = rootUrl else {
            return nil
        }
        do {
            var destinationDocumentsURL: URL = url
            
            destinationDocumentsURL = destinationDocumentsURL
                .appendingPathComponent(subfolder,isDirectory: true)
                .appendingPathComponent(project, isDirectory: true)
                .appendingPathComponent(pickedURL.lastPathComponent)
            var isDir: ObjCBool = false
            if FileManager.default.fileExists(atPath: destinationDocumentsURL.path, isDirectory: &isDir) {
                try FileManager.default.removeItem(at: destinationDocumentsURL)
            }
            guard pickedURL.startAccessingSecurityScopedResource() else {print("problem");return nil}
            defer {
                pickedURL.stopAccessingSecurityScopedResource()
            }
            try FileManager.default.copyItem(at: pickedURL, to: destinationDocumentsURL)
            print(FileManager.default.fileExists(atPath: destinationDocumentsURL.path))
            return destinationDocumentsURL
        } catch  {
            print(error)
        }
        return nil
    }
    /// Remove Project Directory
    /// - Parameter project: project name
    func removeProjectDirectory(project: String) {
        guard let url = rootUrl else {return}
        let localDocumentsURL = url
            .appendingPathComponent(subfolder, isDirectory: true)
            .appendingPathComponent(project, isDirectory: true)
        var isDir: ObjCBool = true
        
        if FileManager.default.fileExists(atPath: localDocumentsURL.path, isDirectory: &isDir) {
            do {
                try FileManager.default.removeItem(at: localDocumentsURL)
            }
            catch {
                print(error)
                //Error handling
                print("Error in remove item")
            }
        }
    }
    /// Remove Document at URL
    /// - Parameter localURL: URL of Document to be removed
    func removeUsingUrl(localURL: URL) {
        do {
            try FileManager.default.removeItem(at: localURL)
        }
        catch {
            print(error)
            //Error handling
            print("Error in remove item")
        }
    }
    
    /// Create Directories for project to store documents inside it
    /// - Parameter project: name of project
    func startupActivities(project: String) {
        createSubFolderDirectory()
        createProjectInsideDocumentsDirectory(project: project)
    }
    /// Create ./Documents/Projects
    func createSubFolderDirectory() {
        guard let url = rootUrl else {
            return
        }
        let newURL = url
            .appendingPathComponent(subfolder,isDirectory: true)
        
        if (!FileManager.default.fileExists(atPath: newURL.path, isDirectory: nil)) {
            do {
                try FileManager.default.createDirectory(at: newURL, withIntermediateDirectories: true, attributes: nil)
            }
            catch {
                //Error handling
                print("Error in creating doc")
            }
        }
    }
    /// Create ./Documents/Projects/<Project name>
    /// - Parameter project: name of project
    func createProjectInsideDocumentsDirectory(project: String) {
        do {
            guard let url = rootUrl else {
                return
            }
            let iCloudDocumentsURL = url
                .appendingPathComponent(subfolder,isDirectory: true)
                .appendingPathComponent(project, isDirectory: true)
            if (!FileManager.default.fileExists(atPath: iCloudDocumentsURL.path, isDirectory: nil)) {
                try FileManager.default.createDirectory(at: iCloudDocumentsURL, withIntermediateDirectories: true, attributes: nil)
            }
        } catch  {
            print(error)
        }
    }
}
