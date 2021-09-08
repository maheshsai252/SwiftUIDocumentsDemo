//
//  iCloudHandler.swift
//  SwiftUIDocumentsDemo (iOS)
//
//  Created by Mahesh sai on 07/09/21.
//

import Foundation
import UIKit

struct iCloudHandler {
    var subfolder: String
    init() {
        subfolder = "Projects"
    }
    /// Return the URL of a document
    /// - Parameters:
    ///   - project: name of project
    ///   - file: name of file
    /// - Returns: URL of file
    func giveURL(project: String, file: String) -> URL? {
        guard var iCloudDocumentsURL = FileManager.default.url(forUbiquityContainerIdentifier: "iCloud.com.maheshsai.pedometer")?
                .appendingPathComponent("Documents", isDirectory: true)
                .appendingPathComponent(subfolder, isDirectory: true)
                .appendingPathComponent(project, isDirectory: true) else {
            return nil
        }
        iCloudDocumentsURL = iCloudDocumentsURL.appendingPathComponent(file , isDirectory: false)
        return iCloudDocumentsURL
    }
    /// Copy the document at pickedURL to iCloudURL
    /// - Parameters:
    ///   - pickedURL: URL of picked document
    ///   - project: project name
    /// - Returns: Local URL of document
    func copyDocumentsToiCloudDirectory(localDocumentsURL: URL, project: String) -> URL? {
        
        guard var iCloudDocumentsURL = FileManager.default.url(forUbiquityContainerIdentifier: "iCloud.com.maheshsai.pedometer")?
                .appendingPathComponent("Documents", isDirectory: true)
                .appendingPathComponent(subfolder, isDirectory: true)
                .appendingPathComponent(project, isDirectory: true)
        else { return nil }
        iCloudDocumentsURL = iCloudDocumentsURL.appendingPathComponent(localDocumentsURL.lastPathComponent , isDirectory: false)
        var isDir: ObjCBool = false
        
        if FileManager.default.fileExists(atPath: iCloudDocumentsURL.path, isDirectory: &isDir) {
            do {
                try FileManager.default.removeItem(at: iCloudDocumentsURL)
            }
            catch {
                print(error)
                //Error handling
                print("Error in remove item")
            }
        }
        
        do {
            print(localDocumentsURL.absoluteString)
            guard localDocumentsURL.startAccessingSecurityScopedResource() else {return nil}
            defer {
                localDocumentsURL.stopAccessingSecurityScopedResource()
            }
            
            try FileManager.default.copyItem(at: localDocumentsURL, to: iCloudDocumentsURL)
            return iCloudDocumentsURL
        }
        catch {
            //Error handling
            print(error)
            print("Error in copy item")
        }
        return nil
    }
    /// Remove Project Directory
    /// - Parameter project: project name
    func removeProjectDirectory(project: String) {
        guard let iCloudDocumentsURL = FileManager.default.url(forUbiquityContainerIdentifier: "iCloud.com.maheshsai.pedometer")?
                .appendingPathComponent("Documents",isDirectory: true)
                .appendingPathComponent(subfolder,isDirectory: true)
                .appendingPathComponent(project,isDirectory: true)
        else { return  }
        var isDir: ObjCBool = true
        
        if FileManager.default.fileExists(atPath: iCloudDocumentsURL.path, isDirectory: &isDir) {
            do {
                try FileManager.default.removeItem(at: iCloudDocumentsURL)
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
    func removeUsingUrl(icloudUrl: URL) {
        do {
            try FileManager.default.removeItem(at: icloudUrl)
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
        createDocumentsDirectory()
        createSubFolderDirectory()
        createProjectInsideDocumentsDirectory(project: project)
    }
    /// Creates ./Documents
    func createDocumentsDirectory() {
        if let iCloudDocumentsURL = FileManager.default.url(forUbiquityContainerIdentifier: "iCloud.com.maheshsai.pedometer")?.appendingPathComponent("Documents", isDirectory: true) {
            if (!FileManager.default.fileExists(atPath: iCloudDocumentsURL.path, isDirectory: nil)) {
                do {
                    try FileManager.default.createDirectory(at: iCloudDocumentsURL, withIntermediateDirectories: true, attributes: nil)
                }
                catch {
                    //Error handling
                    print("Error in creating doc")
                }
            }
        }
    }
    /// Create ./Documents/Projects
    func createSubFolderDirectory() {
        if let iCloudDocumentsURL = FileManager.default.url(forUbiquityContainerIdentifier: "iCloud.com.maheshsai.pedometer")?
            .appendingPathComponent("Documents",isDirectory: true)
            .appendingPathComponent(subfolder,isDirectory: true) {
            if (!FileManager.default.fileExists(atPath: iCloudDocumentsURL.path, isDirectory: nil)) {
                do {
                    try FileManager.default.createDirectory(at: iCloudDocumentsURL, withIntermediateDirectories: true, attributes: nil)
                }
                catch {
                    //Error handling
                    print("Error in creating doc")
                }
            }
        }
    }
    /// Create ./Documents/Projects/<Project name>
    /// - Parameter project: name of project
    func createProjectInsideDocumentsDirectory(project: String) {
        guard let docurl = FileManager.default.url(forUbiquityContainerIdentifier: "iCloud.com.maheshsai.pedometer")?.appendingPathComponent("Documents").appendingPathComponent(subfolder) else {
            return
        }
        let iCloudDocumentsURL = docurl
            .appendingPathComponent(project, isDirectory: true)
        if (!FileManager.default.fileExists(atPath: iCloudDocumentsURL.path, isDirectory: nil)) {
            do {
                try FileManager.default.createDirectory(at: iCloudDocumentsURL, withIntermediateDirectories: true, attributes: nil)
            }
            catch {
                //Error handling
                print("Error in creating doc")
            }
        }
    }
}
