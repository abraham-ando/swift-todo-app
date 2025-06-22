import Foundation

class FileSystemCache: Cache {
    private let fileURL: URL
    
    init(environment: String = "Development",to defaultDirectory: FileManager.SearchPathDirectory = .applicationSupportDirectory,
         filename: String = "todos.json") {
        let directory: URL
        
        if environment == "Production" {
            guard let defaultDirectory = FileManager.default.urls(for: defaultDirectory, in: .userDomainMask).first else {
                fatalError("Could not find application support directory.")
            }
            
            directory = defaultDirectory.appendingPathComponent(filename)
        }
        else {
            let currentDirectory = URL(fileURLWithPath: FileManager.default.currentDirectoryPath)
            directory = currentDirectory.appendingPathComponent("Resources/\(filename)")
            
            if !FileManager.default.fileExists(atPath: directory.path) {
                do {
                    try FileManager.default.createDirectory(at: directory.deletingLastPathComponent(), withIntermediateDirectories: true, attributes: nil)
                    print("📂 Created directory at: \(directory.deletingLastPathComponent().path)")
                } catch {
                    fatalError("Could not create directory: \(error)")
                }
            }
        }
        
        self.fileURL = directory
        print("📂 Cache init at: \(fileURL.path)")
    }
    
    func save(todos: [Todo]) -> Bool {
        do {
            let data = try JSONEncoder().encode(todos)
            try data.write(to: fileURL)
            return true
        } catch {
            print("Error saving cache : \(error)")
            return false
        }
    }
    
    func load() -> [Todo]? {
        guard FileManager.default.fileExists(atPath: fileURL.path) else { return [] }
        do {
            let data = try Data(contentsOf: fileURL)
            return try JSONDecoder().decode([Todo].self, from: data)
        } catch {
            print("Erreur lors du chargement : \(error)")
            return nil
        }
    }
}
