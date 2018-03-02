import Domain

public protocol OrderUseCase  {
    func add(userId: String, orderId: String, itemId: String) -> Error?
    func items(userId: String, orderId: String) -> ([Item], Error?)
}

public protocol AdminOrderUseCase {
    func add(userId: String, orderId: String, itemId: String) -> Error?
}

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

extension OrderInteractor: OrderUseCase {
    public func add(userId: String, orderId: String, itemId: String) -> Error? {
	let (user, error) = userRepo.find(id: userId)
	if let error = error {
	    let errorMsg = "找不到id 为 \(userId) 的 user, error msg is \(error)"
	    logger.logger(errorMsg)
	    return errorMsg
	}
	var (order, error2) = orderRepo.find(id: orderId) 
	if let error2 = error2 {
	    let errorMsg = "找不到id 为 \(orderId) 的 order, error msg is \(error2) "
	    logger.logger(errorMsg)
	    return errorMsg
	}
	let (item, error3) = itemRepo.find(id: itemId) 
	if let error3 = error3 {
	    let errorMsg = "找不到id 为 \(itemId) 的 itemi, error msg is \(error3) "
	    logger.logger(errorMsg)
	    return errorMsg
	}
	guard user.customer.id == order.customerId else {
	    let errorMsg = "订单(customerId:\(order.customerId))不属于该用户(customerId:\(user.customer.id))"
	    logger.logger(errorMsg)
	    return errorMsg
	}
	
	if let error = order.add(item: item) {
	    logger.logger("\(error)")
	    return error
	}

	if let error = orderRepo.store(order) {
	    logger.logger("\(error)")
	    return error
	}

	logger.logger("add item | userId:\(userId) | orderId:\(orderId) | itemId:\(itemId) ")
	return nil
	
    }

   public func items(userId: String, orderId: String) -> ([Item], Error?) {
	let (user, error) = userRepo.find(id: userId)
	if let error = error {
	    let errorMsg = "找不到id 为 \(userId) 的 user, error msg is \(error)"
	    logger.logger(errorMsg)
	    return ([], errorMsg)
	}
	let (order, error2) = orderRepo.find(id: orderId) 
	if let error2 = error2 {
	    let errorMsg = "找不到id 为 \(orderId) 的 order, error msg is \(error2) "
	    logger.logger(errorMsg)
	    return ([], errorMsg)
	}
	guard user.customer.id == order.customerId else {
	    let errorMsg = "订单(customerId:\(order.customerId))不属于该用户(customerId:\(user.customer.id))"
	    logger.logger(errorMsg)
	    return ([], errorMsg)
	}
	let items = order.items.map {
	    Item(id: $0.id, name: $0.name, value: $0.value)
	}
	logger.logger("get items | userId:\(userId) | orderId:\(orderId) ")
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


extension AdminOrderInteractor: AdminOrderUseCase {
    public func add(userId: String, orderId: String, itemId: String) -> Error? {
	let (user, error) = userRepo.find(id: userId)
	if let error = error {
	    let errorMsg = "找不到id 为 \(userId) 的 user, error msg is \(error)"
	    logger.logger(errorMsg)
	    return errorMsg
	}
	guard user.isAdmin else {
	    let errorMsg = "该用户(id: \(user.id))不是管理员"
	    logger.logger(errorMsg)
	    return errorMsg
	}

	var (order, error2) = orderRepo.find(id: orderId) 
	if let error2 = error2 {
	    let errorMsg = "找不到id 为 \(orderId) 的 order, error msg is \(error2) "
	    logger.logger(errorMsg)
	    return errorMsg
	}

	let (item, error3) = itemRepo.find(id: itemId) 
	if let error3 = error3 {
	    let errorMsg = "找不到id 为 \(itemId) 的 itemi, error msg is \(error3) "
	    logger.logger(errorMsg)
	    return errorMsg
	}
	
	if let error = order.add(item: item) {
	    logger.logger("\(error)")
	    return error
	}

	if let error = orderRepo.store(order) {
	    logger.logger("\(error)")
	    return error
	} 
	logger.logger("admin add item | userId:\(userId) | orderId:\(orderId) | itemId:\(itemId) ")
	return nil
    }
}
