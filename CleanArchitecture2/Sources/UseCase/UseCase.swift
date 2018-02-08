import Domain

public protocol UserRepo {
    func store(_ user: User) -> Error?
    func find(id: String) -> (User, Error?)
}

public protocol Logger {
    func logger(_ msg: String)
}

public struct User {
    public let id: String
    public let customer: Customer
    public let isAdmin: Bool

    public init(id: String, customer: Customer, isAdmin: Bool) {
	self.id = id
	self.customer = customer
	self.isAdmin = isAdmin
    }
}

public struct Item {
    public let id: String
    public let name: String
    public let value: Double
    public init(id: String, name: String, value: Double) {
	self.id = id
	self.name = name
	self.value = value
    } 
}

public struct OrderInteractor {
    public let itemRepo: ItemRepo
    public let userRepo: UserRepo
    public let orderRepo: OrderRepo
    public let logger: Logger

    public init(itemRepo: ItemRepo, userRepo: UserRepo, orderRepo: OrderRepo, logger: Logger) {
	self.itemRepo = itemRepo
	self.userRepo = userRepo
	self.orderRepo = orderRepo
	self.logger = logger
    }
}

extension OrderInteractor {
    public func add(userId: String, orderId: String, itemId: String) -> Error? {
	let (user, error) = userRepo.find(id: userId)
	if let error = error {
	    return "找不到id 为 \(userId) 的 user, error msg is \(error)"
	}
	var (order, error2) = orderRepo.find(id: orderId) 
	if let error2 = error2 {
	    return "找不到id 为 \(orderId) 的 order, error msg is \(error2) "
	}
	let (item, error3) = itemRepo.find(id: itemId) 
	if let error3 = error3 {
	    return "找不到id 为 \(itemId) 的 itemi, error msg is \(error3) "
	}
	guard user.customer.id == order.customerId else {
	    return "订单不属于该用户"
	}
	
	if let error = order.add(item: item) {
	    return error
	}
	return orderRepo.store(order)
	
    }

   public func items(userId: String, orderId: String) -> ([Item], Error?) {
	let (user, error) = userRepo.find(id: userId)
	if let error = error {
	    return ([],"找不到id 为 \(userId) 的 user, error msg is \(error)")
	}
	let (order, error2) = orderRepo.find(id: orderId) 
	if let error2 = error2 {
	    return ([],"找不到id 为 \(orderId) 的 order, error msg is \(error2) ")
	}
	guard user.customer.id == order.customerId else {
	    return ([],"订单不属于该用户")
	}
	let items = order.items.map {
	    Item(id: $0.id, name: $0.name, value: $0.value)
	}
	return (items, nil)
   }
}

public struct AdminOrderInteractor {
    public let itemRepo: ItemRepo
    public let userRepo: UserRepo
    public let orderRepo: OrderRepo
    public let logger: Logger

    public init(itemRepo: ItemRepo, userRepo: UserRepo, orderRepo: OrderRepo, logger: Logger) {
	self.itemRepo = itemRepo
	self.userRepo = userRepo
	self.orderRepo = orderRepo
	self.logger = logger
    }
}

extension AdminOrderInteractor {
    public func add(userId: String, orderId: String, itemId: String) -> Error? {
	let (user, error) = userRepo.find(id: userId)
	if let error = error {
	    return "找不到id 为 \(userId) 的 user, error msg is \(error)"
	}
	guard user.isAdmin else {
	    return "该用户不是管理员"
	}
	var (order, error2) = orderRepo.find(id: orderId) 
	if let error2 = error2 {
	    return "找不到id 为 \(orderId) 的 order, error msg is \(error2) "
	}
	let (item, error3) = itemRepo.find(id: itemId) 
	if let error3 = error3 {
	    return "找不到id 为 \(itemId) 的 itemi, error msg is \(error3) "
	}
	if let error = order.add(item: item) {
	    return error
	}
	return orderRepo.store(order)
    }
}
