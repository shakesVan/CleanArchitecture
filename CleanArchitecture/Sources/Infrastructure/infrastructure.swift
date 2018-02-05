import Interface
import SQLite

public struct SqliteHandler {
    fileprivate var sqlDB: Connection
    public init(dbfileName: String) {
        sqlDB = try! Connection(dbfileName)
    }
}

extension SqliteHandler: Interface.DbHandler {
    public func execute(statement: String) {
        do {
            try sqlDB.execute(statement)
        } catch let error {
            print(error)
        }
    }

    public func query(statement: String) -> [Any] {
        do {
            let results = try sqlDB.prepare(statement)
            var array: [Any] = []
            for result in results {
                array.append(result)
            }
            return array
        } catch let error {
            print(error)
        }
        return []
        
    }
}

