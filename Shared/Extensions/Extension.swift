//
//  Extension.swift
//  SwiftUIDocumentsDemo (iOS)
//
//  Created by Mahesh sai on 07/09/21.
//

import Foundation

extension URL {
    /// check if the URL is a directory and if it is reachable
    func isDirectoryAndReachable() throws -> Bool {
        guard try resourceValues(forKeys: [.isDirectoryKey]).isDirectory == true else {
            return false
        }
        return try checkResourceIsReachable()
    }

    /// returns total allocated size of a the directory including its subFolders or not
    func directoryTotalAllocatedSize(includingSubfolders: Bool = false) throws -> Int? {
        guard try isDirectoryAndReachable() else { return nil }
        if includingSubfolders {
            guard
                let urls = FileManager.default.enumerator(at: self, includingPropertiesForKeys: nil)?.allObjects as? [URL] else { print("prob else");return nil }
            return try urls.lazy.reduce(0) {
                    (try $1.resourceValues(forKeys: [.totalFileAllocatedSizeKey]).totalFileAllocatedSize ?? 0) + $0
            }
        }
        return try FileManager.default.contentsOfDirectory(at: self, includingPropertiesForKeys: nil).lazy.reduce(0) {
                 (try $1.resourceValues(forKeys: [.totalFileAllocatedSizeKey])
                    .totalFileAllocatedSize ?? 0) + $0
        }
    }

    /// returns the directory total size on disk
    func sizeOnDisk() throws -> Double? {
        guard let size = try directoryTotalAllocatedSize(includingSubfolders: true) else { print("prob");return nil }
        return Double(size)
    }
    private static let byteCountFormatter = ByteCountFormatter()
}
extension URL {
    func byteCount(size: Double) -> String? {
        URL.byteCountFormatter.countStyle = .file
        guard let byteCount = URL.byteCountFormatter.string(for: size) else { print("conv");return nil}
        return byteCount
    }
}

extension URL {
    
    var fileSize: Int? {
        let _  = self.startAccessingSecurityScopedResource()
        defer {
            self.stopAccessingSecurityScopedResource()
        }
        let value = try? resourceValues(forKeys: [.fileSizeKey])
        return value?.fileSize
    }
    var fileMBSize: Double {
        let filePath = self.path
           do {
               let attribute = try FileManager.default.attributesOfItem(atPath: filePath)
               if let size = attribute[FileAttributeKey.size] as? NSNumber {
                   return size.doubleValue / 1000000.0
               }
           } catch {
               print("Error: \(error)")
           }
           return 0.0
    }
    var directorySize: Int? {
        let value = try? resourceValues(forKeys: [.isDirectoryKey])
        return value?.fileSize
    }
}
