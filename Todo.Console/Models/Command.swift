import Foundation

enum Command: String {
    case add, list, toggle, delete, help, exit, unknown
    
    static func from(_ input: String) -> Command {
        return Command(rawValue: input.lowercased()) ?? .unknown
    }
}
