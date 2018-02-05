import Entities

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
    
    public init(id :String, name: String, value: Double) {
        self.id = id
        self.name = name
        self.value = value
    }
}

public protocol UserRepo {
    func store(_ user: User) -> MYError?
    func find(by id: String) -> (User, MYError?)
}

public protocol Logger {
    func logger(msg: String) 
}

public struct OrderInteractor {
    public var userRepo: UserRepo
    public var itemRepo: Entities.ItemRepo
    public var orderRepo: Entities.OrderRepo
    public var logger: Logger
    public init(userRepo: UserRepo, itemRepo: Entities.ItemRepo, orderRepo: Entities.OrderRepo, logger: Logger) {
        self.userRepo = userRepo
        self.itemRepo = itemRepo
        self.orderRepo = orderRepo
        self.logger = logger
    }
}

extension OrderInteractor {
    public func add(userId: String, orderId: String, itemId: String) -> Error? {
        let (user,_) = userRepo.find(by: userId)
        var (order,_) = orderRepo.find(by: orderId)
        guard user.customer.id == order.customerId else {
            let msg = "user customer id is \(user.customer.id),if default by order customerId \(order.customerId)"
            return MYError(msg: msg)
        }
        let (item,_) = itemRepo.find(by: itemId)
        if let error = order.add(item: item) {
            return error
        }
        logger.logger(msg: "add success")
        return nil
    }
    
    public func items(userId: String, orderId: String) -> ([Item],Error?) {
        
        let (user,_) = userRepo.find(by: userId)
        let (order,_) = orderRepo.find(by: orderId)
        guard user.customer.id == order.customerId else {
            let msg = "user customer id is \(user.customer.id),if default by order customerId \(order.customerId)"
            return ([], MYError(msg: msg))
        }
        let items = order.items.map {
            Item(id: $0.id, name: $0.name, value: $0.value)
        }
        return (items, nil)
    }
    
}

public struct AdminOrderInteractor {
    public var userRepo: UserRepo
    public var itemRepo: ItemRepo
    public var orderRepo: OrderRepo
    public var logger: Logger
}
extension AdminOrderInteractor {
    public func add(userId: String, orderId: String, itemId: String) -> Error? {
        let (user, _) = userRepo.find(by: userId)
        guard user.isAdmin else {
            return MYError(msg: "非管理员")
        }
        var (order, _) = orderRepo.find(by: orderId)
        let (item, _) = itemRepo.find(by: itemId)
        if let error = order.add(item: item) {
            return error
        }
        logger.logger(msg: "admin add success")
        return nil
    }
}
