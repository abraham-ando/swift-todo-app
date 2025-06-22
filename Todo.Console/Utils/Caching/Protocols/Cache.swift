protocol Cache {
    func save(todos: [Todo]) -> Bool
    func load() -> [Todo]?
}
