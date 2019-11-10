import jq

final public class JQ {
    private var state: OpaquePointer!
    
    public init(query: String) throws {
        guard let state = jq_init() else {
            throw JQError.system
        }
        self.state = state
        
        let hasCompiled = query.withCString { chars in
            return jq_compile(self.state, chars) != 0
        }
        if !hasCompiled {
            throw JQError.compile
        }
    }
    
    public func executeOne(input: String) throws -> String {
        let inputStringJV = input.withCString { chars in
            return jv_parse_sized(chars, Int32(input.utf8.count))
        }
        // seems freed by the library, since if I free it, the program would screw up, and even if I don't free them, I didn't see memory leak
//        defer { jv_free(inputStringJV) }
        if jv_is_valid(inputStringJV) == 0 {
            throw JQWrapperError.parse(message: getInvalidMessage(of: inputStringJV))
        }
        
        jq_start(self.state, inputStringJV, 0)
        let result = jq_next(self.state)
        // ditto
//        defer { jv_free(result) }
        if jv_is_valid(result) == 0 {
            throw JQWrapperError.execute(message: getInvalidMessage(of: result))
        }
        
        let resultStringJV = jv_dump_string(result, 0)
        defer { jv_free(resultStringJV) }
        if jv_is_valid(resultStringJV) == 0 {
            throw JQWrapperError.unknown(message: getInvalidMessage(of: resultStringJV))
        }
        let resultChars = jv_string_value(resultStringJV)!
        
        while true {
            let temp = jq_next(self.state)
            defer { jv_free(temp) }
            if jv_is_valid(temp) == 0 {
                if jv_invalid_has_msg(temp) == 0 {
                    break
                }
                throw JQWrapperError.execute(message: getInvalidMessage(of: temp))
            }
        }
        
        return String(cString: resultChars)
    }
    
    deinit {
        jq_teardown(&self.state)
    }
    
}

internal func getInvalidMessage(of value: jv) -> String? {
    if jv_invalid_has_msg(value) == 0 {
        return nil
    }
    let message = jv_invalid_get_msg(value)
    guard let chars = jv_string_value(message) else {
        return nil
    }
    return String(cString: chars)
}
