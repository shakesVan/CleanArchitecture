import Interface
import SQLite

public struct SqliteHandler {
    public let db: Connection
    public init(filename: String) {
	db = try! Connection(filename)
    }
}

extension SqliteHandler: DbHandler {
    public func execute(_ statement: String) -> Error? {
	do {
	    try db.execute(statement)
	    
	} catch let error {
	    return error
	}
	return nil
    }

    public func prepare(_ statement: String) -> [Any] {
	do {
	    let rows = try db.prepare(statement)
	    var result = [Any]()
	    for row in rows {
		result.append(row)
	    }
		
	} catch {
	}
	return []
    }
}
