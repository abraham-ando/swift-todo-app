import Foundation

struct Todo: Codable, CustomStringConvertible {
    let id: UUID
    var title: String
    var isCompleted: Bool
    
    init(title: String, isCompleted: Bool = false) {
        self.id = UUID()
        self.title = title
        self.isCompleted = isCompleted
    }
    
    var description: String {
        let status = isCompleted ? "✅" : "❌"
        return "\(status) \(title)"
    }
}

enum Command: String {
    case add, list, toggle, delete, help, exit, unknown
    
    static func from(_ input: String) -> Command {
        return Command(rawValue: input.lowercased()) ?? .unknown
    }
}

protocol Cache {
    func save(todos: [Todo]) -> Bool
    func load() -> [Todo]?
}

class InMemoryCache: Cache {
    private var storage: [Todo] = []
    func save(todos: [Todo]) -> Bool {
        storage = todos
        return true
    }
    func load() -> [Todo]? {
        return storage
    }
}

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

class TodosManager {
    private(set) var tasks: [Todo] = []
    private let cache: Cache
    
    init(cache: Cache) {
        self.cache = cache
        self.tasks = cache.load() ?? []
    }
    
    func addTodo(_ title: String) {
        tasks.append(Todo(title: title))
        _ = cache.save(todos: tasks)
        print("📌 Todo added!")
    }
    
    func listTodos() {
        if tasks.isEmpty {
            print("📋 Empty todo list. Add some todo!")
        } else {
            print("📝 Your Todos:")
            for (index, task) in tasks.enumerated() {
                print("\(index + 1). \(task)")
            }
        }
    }
    
    func toggleCompletion(forTodoAtIndex index: Int) {
        guard index >= 0 && index < tasks.count else {
            print("❗️ Invalid todo number.")
            return
        }
        tasks[index].isCompleted.toggle()
        _ = cache.save(todos: tasks)
        print("🔄 Todo completion status toggled!")
    }
    
    func deleteTodo(at index: Int) {
        guard index >= 0 && index < tasks.count else {
            print("❗️ Invalid todo number.")
            return
        }
        let removedTask = tasks.remove(at: index)
        _ = cache.save(todos: tasks)
        print("🗑️ Delete task : '\(removedTask.title)'")
    }
}

class App {
    let manager: TodosManager
    
    init(cache: Cache) {
        self.manager = TodosManager(cache: cache)
    }
    
    func run() {
        print("🌟 Welcome to Todo CLI! 🌟")
        
        while true {
            print("\nWhat would you like to do? (add, list, toggle, delete, exit): ", terminator: "")
            let input = readLine() ?? "help"
            let command = Command.from(input)
            switch command {
            case .add:
                print("🔹 Enter todo title: ", terminator: "")
                if let task = readLine(), !task.isEmpty {
                    manager.addTodo(task)
                }
            case .list:
                manager.listTodos()
            case .toggle:
                manager.listTodos()
                print("🔹 Enter the number of the todo to toggle:", terminator: "")
                if let input = readLine(), let index = Int(input), index > 0 {
                    manager.toggleCompletion(forTodoAtIndex: index - 1)
                } else {
                    print("❗️ Invalid input. Please enter a valid todo number.")
                }
            case .delete:
                manager.listTodos()
                print("🔹 Enter the number of the todo to delete:", terminator: "")
                if let input = readLine(), let index = Int(input), index > 0 {
                    manager.deleteTodo(at: index - 1)
                } else {
                    print("❗️ Invalid input. Please enter a valid todo number.")
                }
            case .help:
                printHelp()
            case .exit:
                print("👋 Thanks for using Todo CLI! See you next time!")
                return
            case .unknown:
                printHelp()
            }
        }
    }
}

func printHelp() {
    print("""
    📖 Available commands:
    - add: To add a todo, type 'add' and then enter the title.
    - list: To list todos, type 'list'.
    - toggle: To toggle a todo, type 'toggle' and then enter the number of the todo.
    - delete: To delete a todo, type 'delete' and then enter the number of the todo.
    - help: To see this help message, type 'help'.
    - exit: To exit the application, type 'exit'.
    """)
}

// Choix du cache : FileSystemCache() pour la persistance, InMemoryCache() pour la mémoire vive
let app = App(cache: FileSystemCache())
app.run()
