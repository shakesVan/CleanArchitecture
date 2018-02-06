import Domain

public protocol UserRepo {
    func store(_ user: User) -> Error?
    func find(id: String) -> User?
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
	guard let user = userRepo.find(id: userId) else {
	    return "找不到id 为 \(userId) 的 user"
	}
	guard var order = orderRepo.find(id: orderId) else {
	    return "找不到id 为 \(orderId) 的 order "
	}
	guard let item = itemRepo.find(id: itemId) else {
	    return "找不到id 为 \(itemId) 的 item "
	}
	guard user.customer.id == order.customerId else {
	    return "订单不属于该用户"
	}

	return order.add(item: item) 
    }

   public func items(userId: String, orderId: String) -> ([Item], Error?) {
	guard let user = userRepo.find(id: userId) else {
	    return ([], "找不到id 为 \(userId) 的 user")
	}
	guard let order = orderRepo.find(id: orderId) else {
	    return ([], "找不到id 为 \(orderId) 的 order ")
	}
	guard user.customer.id == order.customerId else {
	    return ([], "订单不属于该用户")
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
	guard let user = userRepo.find(id: userId) else {
	    return "找不到id 为 \(userId) 的 user"
	}
	guard user.isAdmin else {
	    return "该用户不是管理员"
	}
	guard var order = orderRepo.find(id: orderId) else {
	    return "找不到id 为 \(orderId) 的 order "
	}
	guard let item = itemRepo.find(id: itemId) else {
	    return "找不到id 为 \(itemId) 的 item "
	}

	return order.add(item: item) 
    }
}
