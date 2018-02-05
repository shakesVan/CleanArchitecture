import Entities
import UseCase
import Foundation

public protocol DbHandler {
    
    func execute(statement: String)
    func query(statement: String) -> [Any]
}



public class DbRepo {
    public var dbHandlers: [String: DbHandler]
    public var dbHandler: DbHandler
    public init(dbHandler: DbHandler, dbHandlers: [String: DbHandler]) {
        self.dbHandler = dbHandler
        self.dbHandlers = dbHandlers
    }
}

public class DbUserRepo: DbRepo {
    public static func repo(dbHandlers: [String: DbHandler]) -> DbUserRepo {
        let dbHandler: DbHandler = dbHandlers["DbUserRepo"]!
        let repo = DbUserRepo(dbHandler: dbHandler, dbHandlers: dbHandlers)
        return repo
    }
}

extension DbUserRepo: UserRepo {
    public func store(_ user: User) -> Entities.MYError? {
        let statement = "INSERT INTO users (id, customer_id, is_admin) VALUES (\(user.id), \(user.customer.id), \(user.isAdmin)"
        dbHandler.execute(statement: statement)
        let customerRepo = DbCustomerRepo.repo(dbHandlers: dbHandlers)
        
        return customerRepo.store(user.customer)
    }

    public func find(by id: String) -> (User, Entities.MYError?) {
        let statement = "SELECT is_admin, customer_id FROM users WHERE id = \(id) LIMIT 1 "
        let rows = dbHandler.query(statement: statement)
        var isAdmin = false
        var customerId = ""
        if let row = rows.first as? [Any] {
            isAdmin = (row[0] as! Int64) == 1
            customerId = row[1] as! String
        }

        let customerRepo = DbCustomerRepo.repo(dbHandlers: dbHandlers)
        let (customer, _) = customerRepo.find(by: customerId)
        let user = User(id: id, customer: customer, isAdmin: isAdmin)
        return (user, nil)
    }
}

public class DbCustomerRepo: DbRepo {
    public static func repo(dbHandlers: [String: DbHandler]) -> DbCustomerRepo {
        let dbHandler = dbHandlers["DbCustomerRepo"]!
        let repo = DbCustomerRepo(dbHandler: dbHandler, dbHandlers: dbHandlers)
        return repo
    }
}

extension DbCustomerRepo: CustomerRepo {
    public func store(_ customer: Customer) -> Entities.MYError? {
        let statement = "INSERT INTO customers (customer_id, name) VALUES (\(customer.id), \(customer.name)"
        dbHandler.execute(statement: statement)
        return nil
    }
    
    public func find(by id: String) -> (Customer, Entities.MYError?) {
        let statement = "SELECT name FROM customers WHERE id = \(id) LIMIT 1 "
        let rows = dbHandler.query(statement: statement)
        var name = ""
        if let row = rows.first as? [String] {
            name = row[0]
        }
        let customer = Customer(id: id, name: name)
        return (customer, nil)
    }
}


public class DbItemRepo: DbRepo {
    public static func repo(dbHandlers: [String: DbHandler]) -> DbItemRepo {
        let dbHandler = dbHandlers["DbItemRepo"]!
        let repo = DbItemRepo(dbHandler: dbHandler, dbHandlers: dbHandlers)
        return repo
    }
}
extension DbItemRepo: ItemRepo {
    public func store(_ item: Entities.Item) -> Entities.MYError? {
        let statement = "INSERT INTO items (item_id, name, value, available) VALUE (\(item.id), \(item.name), \(item.value), \(item.available)"
        dbHandler.execute(statement: statement)
        return nil
    }
    
    public func find(by itemId: String) -> (Entities.Item, Entities.MYError?) {
        let statement = "SELECT name, value, available FROM items Where id = \(itemId) LIMIT 1"
        let rows = dbHandler.query(statement: statement)
        
        var name = ""
        var value = 0.0
        var available = false
        
        if let row = rows.first as? [Any] {
            name = row[0] as! String
            value = row[1] as! Double
            available = (row[2] as! Int64) == 1
        }
        let item = Entities.Item(id: itemId, name: name, value: value, available: available)
        return (item, nil)
    }
}

public class DbOrderRepo: DbRepo {
    public static func repo(dbHandlers: [String: DbHandler]) -> DbOrderRepo {
        let dbHandler = dbHandlers["DbOrderRepo"]!
        let repo = DbOrderRepo(dbHandler: dbHandler, dbHandlers: dbHandlers)
        return repo
    }
}

extension DbOrderRepo: OrderRepo {
    public func store(_ order: Entities.Order) -> Entities.MYError? {
        let statement = "INSERT INTO orders (order_id, customer_id) VALUE (\(order.id), \(order.customerId)"
        dbHandler.execute(statement: statement)
        for item in order.items {
            let sta = "INSERT INTO items2orders (order_id, item_id) VALUES (\(order.id), \(item.id)"
            dbHandler.execute(statement: sta)
        }
        return nil
    }
    
    public func find(by orderId: String) -> (Entities.Order, Entities.MYError?) {
        let statement = "SELECT customer_id FROM orders WHERE id = \(orderId) LIMIT 1"
        let rows = dbHandler.query(statement: statement)
        guard let row = rows.first as? [String] else {
            let order = Order(id: "", customerId: "", items: [])
            let error = Entities.MYError(msg: "未查询到数据")
            return (order, error)
        }
        
        var customerId = ""
        customerId = row[0]
        
        let o2iSta = "SELECT item_id FROM items2orders WHERE order_id = \(orderId)"
        let o2iRows = dbHandler.query(statement: o2iSta) as! [[String]]
        var items: [Entities.Item] = []
        for o2iRow in o2iRows {
            let itemId = o2iRow[0]
            let dbItemRepo = DbItemRepo.repo(dbHandlers: dbHandlers)
            let (item, _) = dbItemRepo.find(by: itemId)
            items.append(item)
            
        }
        let order = Order(id: orderId, customerId: customerId, items: items)
        
        return (order, nil)
    }
}

