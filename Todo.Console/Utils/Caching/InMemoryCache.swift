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
