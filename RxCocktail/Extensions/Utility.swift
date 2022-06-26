//
//  Utility.swift
//  RxCocktail
//
//  Created by Leonardo Diaz on 6/23/22.
//

import UIKit

struct Utility {
    static func getAppDirectory() -> URL {
        let fileManager = FileManager.default
        
        let paths = fileManager.urls(for: .documentDirectory, in: .userDomainMask)
        let appDirectory = paths[0].appendingPathComponent("RxCocktail")
        
        if !fileManager.fileExists(atPath: appDirectory.relativePath) {
            try? fileManager.createDirectory(at: appDirectory, withIntermediateDirectories: false, attributes: nil)
        }
        
        return appDirectory
    }

   static func saveImage(image: UIImage?, id: String) -> URL? {
        if let image = image {
            if let data = image.pngData() {
                let filename = getAppDirectory().appendingPathComponent("\(id).png")
                try? data.write(to: filename)
                return filename
            }
        }
        return nil
    }
    
    static func removeImage(id: String) {
        let filename = getAppDirectory().appendingPathComponent("\(id).png")
        do {
            try FileManager.default.removeItem(at: filename)
        } catch let error as NSError {
            print("Error deleting image in \(#function) : \(error.localizedDescription) \n---\n \(error)")
        }
    }
    
    
    static func loadImageData(id: String, completion: @escaping (Data) -> Void) {
        let filename = getAppDirectory().appendingPathComponent("\(id).png")
        do {
             let data = try Data(contentsOf: filename)
            completion(data)
        } catch {
            print("Error loading Image Data from URL \(#function) : \(error.localizedDescription) \n---\n \(error)")
        }
    }
}
