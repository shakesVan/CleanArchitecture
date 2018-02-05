public struct MYError: Error {
    public let msg: String
    public init(msg :String) {
        self.msg = msg
    }
}

public protocol ItemRepo {
    func store(_ item: Item) -> MYError?
    func find(by id: String) -> (Item, MYError?)
}

public protocol CustomerRepo {
    func store(_ customer: Customer) -> MYError?
    func find(by id: String) -> (Customer, MYError?)
}

public protocol OrderRepo {
    func store(_ order: Order) -> MYError?
    func find(by id: String) -> (Order, MYError?)
}

public struct Item{
    public let id: String
    public let name: String
    public let value: Double
    public let available: Bool
    
    public init(id :String, name: String, value: Double, available: Bool) {
        self.id = id
        self.name = name
        self.value = value
        self.available = available
    }
}

public struct Customer {
    public let id: String
    public let name: String
    
    public init(id: String, name: String) {
        self.id = id
        self.name = name
    }
}

public struct Order {
    public let id: String
    public let customerId: String
    public var items: [Item]
    
    public init(id: String, customerId: String, items: [Item]) {
        self.id = id
        self.customerId = customerId
        self.items = items
    }
}

extension Order {
    public mutating func add(item: Item) -> MYError? {
        guard item.available else {
            return MYError(msg: "item aviable is false")
        }
        items.append(item)
        return nil
    }
    
    public func value() -> Double{
        
        var value: Double = 0
        for item in items {
            value += item.value
        }
        return value
    }
}
