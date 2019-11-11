public enum JQError: Error {
    case system
    case compile
    case unknown
}

public extension JQError {
    var strerror: Int? {
        switch self {
        case .system:
            return 2
        case .compile:
            return 3
        case .unknown:
            return 5
//        default:
//            return nil
        }
    }
}

public enum JQWrapperError: Error {
    case parse(message: String?)
    case execute(message: String?)
    case unknown(message: String?)
}
