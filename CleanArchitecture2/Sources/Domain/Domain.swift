// Domain

public protocol ItemRepo {
    func store(_ item: Item) -> Error?
    func find(id: String) -> Item?
}

public protocol CustomerRepo {
    func store(_ customer: Customer) -> Error? 
    func find(id: String) -> Customer?
}

public protocol OrderRepo {
    func store(_ order: Order) -> Error? 
    func find(id: String) -> Order?
}

public struct Item {
    public let id: String 
    public let name: String
    public let value: Double
    public let available: Bool
    
    public init(id: String, name: String, value: Double, available: Bool) {
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
    
    public init(id: String, customerId: String, items: [Item] = []) {
	self.id = id 
	self.customerId = customerId
	self.items = items
    }
}

extension Order {
    public mutating func add(item: Item) -> Error? {
	guard item.available else {
	    return "商品不可购买"
	}

	guard value() > 250 else {
	    return "订单金额不能超过250美元"
	}
	self.items.append(item)
	return nil
    }

    public func value() -> Double {
	var value = 0.0
	for item in items {
	    value = value + item.value
	}
	return value
    }
}


