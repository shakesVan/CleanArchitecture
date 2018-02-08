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

    public func find(id: String) -> (Domain.Item,Error?) {
	let statement = "SELECT name, value, available FROM items WHERE id = \(id) LIMIT 1;"
	guard let rows = dbHandler.prepare(statement) as? [[Any]],
	    let row = rows.first,
	    let name = row[0] as? String,
	    let value = row[1] as? Double,
	    let avai = row[2] as? Int64 else {
	    let error = "获取Item失败"
	    let item = Domain.Item(id: "", name: "", value: 0.0, available: false)
	    return (item, error)
	}
	let available = avai == 1
	let item = Domain.Item(id: id, name: name, value: value, available: available)
	return (item, nil)
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

    public func find(id: String) -> (Customer, Error?) {
	let statement = "SELECT name FROM customers WHERE id = \(id) LIMIT 1;"
	let result = dbHandler.prepare(statement)
	guard let rows = result as? [[String]],
	    let row = rows.first,
	    let name = row.first else {
	    let error = "获取id(\(id))的 Customer 失败"
	    let customer = Customer(id: "", name: "") 

	    return (customer, error)
	}
	let customer = Customer(id: id, name: name) 
	return (customer, nil)
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
	let customerRepo = DbCustomerRepo.repo(dbHandlers: dbHandlers)
	return customerRepo.store(user.customer)
    }

    public func find(id: String) -> (User, Error?) {
	let statement = "SELECT customer_id, is_admin FROM users WHERE id = \(id) LIMIT 1;"
	let errorUser = User(id: "", customer: Customer(id: "", name: ""), isAdmin: false)
	let result = dbHandler.prepare(statement) 
	guard let rows = result as? [[Any]],
	    let row = rows.first,
	    let customerId = row[0] as? String,
	    let admin = row[1] as? Int64 else {
	    return (errorUser, "获取customerId 或者 admin 失败,result is \(result) ,userId is \(id)")
	}
	let isAdmin = admin == 1
	let customerRepo = DbCustomerRepo.repo(dbHandlers: dbHandlers)
	let (customer, customerError) = customerRepo.find(id: customerId)
	if let error = customerError {
	    return (errorUser, "获取customer失败, error is \(error)")
	}
	let user = User(id: id, customer: customer, isAdmin: isAdmin)
	return (user, nil)
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
	let delSta = "DELETE FROM orders WHERE id = \(order.id)"
	_ = dbHandler.execute(delSta)
	let delItemSta = "DELETE FROM items2orders WHERE order_id = \(order.id)"
	_ = dbHandler.execute(delItemSta)

	let statement = "INSERT INTO orders (id, customer_id) VALUES (\(order.id), \(order.customerId));"
	if let error = dbHandler.execute(statement) {
	    return error
	}
	for item in order.items {
	    let sta = "INSERT INTO items2orders (item_id, order_id) VALUES (\(item.id), \(order.id));"
	    if let error = dbHandler.execute(sta) {
		return error
	    }
	}
	return nil

    }

    public func find(id: String) -> (Order, Error?) {

	let statement = "SELECT customer_id FROM orders WHERE id = \(id) LIMIT 1;"
	let errorOrder = Order(id: "", customerId: "", items: [])
	guard let rows = dbHandler.prepare(statement) as? [[String]],
	    let row = rows.first,
	    let customerId = row.first  else {
	    return (errorOrder, "获取customerId失败")
	}
	let sta = "SELECT item_id FROM items2orders WHERE order_id = \(id);"
	let result = dbHandler.prepare(sta)
	guard let itemRows = result as? [[String]] else {
	    return (errorOrder, "获取itemIds失败")
	}
	let itemRepo = DbItemRepo.repo(dbHandlers: dbHandlers)
	var items = [Domain.Item]()
	for itemRow in itemRows {
	    guard let itemId = itemRow.first else {
		return (errorOrder, "获取itemId失败")
	    }
	    let (item, error) = itemRepo.find(id: itemId) 
	    if let error = error {
		return (errorOrder, "获取itemId(\(itemId))的item失败 error is \(error)")
	    }
	    items.append(item)
	} 

	let order = Order(id: id, customerId: customerId, items: items)
	return (order, nil)
    }

}
