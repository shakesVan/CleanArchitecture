import Domain
import UseCase

public protocol DbHandler {
    func execute(_ statement: String) -> Error?
    func prepare(_ statement: String) -> [Any]
}

public class DbRepo {
    public var dbHandler: DbHandler
    public var dbHandlers: [String: DbHandler]
    
    public init(dbHandler: DbHandler, dbHandlers: [String: DbHandler]) {
	self.dbHandler = dbHandler
	self.dbHandlers = dbHandlers
    }

}

public class DbItemRepo: DbRepo{
    public static func repo(dbHandlers: [String: DbHandler]) -> DbItemRepo {
	let repo = dbHandlers["DbItemRepo"]!
	return DbItemRepo(dbHandler: repo, dbHandlers: dbHandlers)
    }
}

extension DbItemRepo: ItemRepo {
    public func store(_ item: Domain.Item) -> Error? {
	let statement = "INSERT INTO items (id, name, value, available) VALUES (\(item.id), \(item.name), \(item.value),\( item.available));"
	return dbHandler.execute(statement)
    }

    public func find(id: String) -> Domain.Item? {
	let statement = "SELECT name, value, available FROM items WHERE id = \(id) LIMIT 1;"
	guard let rows = dbHandler.prepare(statement) as? [[Any]],
	    let row = rows.first,
	    let name = row[0] as? String,
	    let value = row[1] as? Double,
	    let avai = row[2] as? Int64 else {
	    return nil
	}
	let available = avai == 1
	let item = Domain.Item(id: id, name: name, value: value, available: available)
	return item
    }
}

public class DbCustomerRepo: DbRepo{
    public static func repo(dbHandlers: [String: DbHandler]) -> DbCustomerRepo {
	let repo = dbHandlers["DbCustomerRepo"]!
	return DbCustomerRepo(dbHandler: repo, dbHandlers: dbHandlers)
    }
}

extension DbCustomerRepo: CustomerRepo {
    public func store(_ customer: Customer) -> Error? {
	let statement = "INSERT INTO customers (id, name) VALUES (\(customer.id), \(customer.name))); "
	return dbHandler.execute(statement)
    }

    public func find(id: String) -> Customer? {
	let statement = "SELECT name FROM customers WHERE id = \(id) LIMIT 1;"
	guard let rows = dbHandler.prepare(statement) as? [String],
	    let name = rows.first else {
	    return nil
	}
	let customer = Customer(id: id, name: name) 
	return customer
    }
    
}

public class DbUserRepo: DbRepo{
    public static func repo(dbHandlers: [String: DbHandler]) -> DbUserRepo {
	let repo = dbHandlers["DbUserRepo"]!
	return DbUserRepo(dbHandler: repo, dbHandlers: dbHandlers)
    }
}

extension DbUserRepo: UserRepo {
    public func store(_ user: User) -> Error? {
	let statement = "INSERT INTO users (id, customerId, isAdmin) VALUES (\(user.id), \(user.customer.id));"
	
	if let error = dbHandler.execute(statement) {
	    return error
	}
	guard let repo = dbHandlers["DbCustomerRepo"],
	    let customerRepo = repo as? DbCustomerRepo else {
	    return "customerRepo type error"
	}
	return customerRepo.store(user.customer)
    }

    public func find(id: String) -> User? {
	let statement = "SELECT customerId, isAdmin FROM users WHERE id = \(id) LIMIT 1;"
	guard let rows = dbHandler.prepare(statement) as? [[Any]],
	    let row = rows.first,
	    let customerId = row[0] as? String,
	    let admin = row[1] as? Int64 else {
	    return nil
	}
	let isAdmin = admin == 1
	
	guard let repo = dbHandlers["DbCustomerRepo"],
	    let customerRepo = repo as? DbCustomerRepo else {
	    return nil 
	}
	guard let customer = customerRepo.find(id: customerId) else {
	    return nil
	}
	let user = User(id: id, customer: customer, isAdmin: isAdmin)
	return user
    }
    
} 

public class DbOrderRepo: DbRepo{
    public static func repo(dbHandlers: [String: DbHandler]) -> DbOrderRepo {
	let repo = dbHandlers["DbOrderRepo"]!
	return DbOrderRepo(dbHandler: repo, dbHandlers: dbHandlers)
    }
}

extension DbOrderRepo: OrderRepo {
    public func store(_ order: Order) -> Error? {
	let statement = "INSERT INTO orders (id, customerId) VALUES (\(order.id), \(order.customerId));"
	if let error = dbHandler.execute(statement) {
	    return error
	}
	for item in order.items {
	    let sta = "INSERT INTO items2orders (itemId, orderId) VALUES (\(item.id), \(order.id));"
	    if let error = dbHandler.execute(sta) {
		return error
	    }
	}
	return nil

    }

    public func find(id: String) -> Order? {
	let statement = "SELECT customerId FROM orders WHERE id = \(id) LIMIT 1;"
	guard let rows = dbHandler.prepare(statement) as? [String],
	    let customerId = rows.first else {
	    return nil
	}
	let sta = "SELECT itemId FROM orders WHERE id = \(id);"
	guard let itemIds = dbHandler.prepare(sta) as? [String] else {
	    return nil
	}
	let itemRepo = DbItemRepo.repo(dbHandlers: dbHandlers)
	var items = [Domain.Item]()
	for itemId in itemIds {
	    guard let item = itemRepo.find(id: itemId) else {
		return nil
	    }
	    items.append(item)
	}
    

	let order = Order(id: id, customerId: customerId, items: items)
	return order
    }

}
