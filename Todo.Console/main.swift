import Foundation

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

// Choice caching : FileSystemCache or InMemoryCache
let app = App(cache: InMemoryCache())
app.run()
