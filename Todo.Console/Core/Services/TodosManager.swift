import Foundation

final class TodosManager {
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
