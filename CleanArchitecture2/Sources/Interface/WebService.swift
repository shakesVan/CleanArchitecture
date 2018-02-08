import UseCase
import Kitura

public protocol OrderInteractor {
    func add(userId: String, orderId: String, itemId: String) -> Error?
    func items(userId: String, orderId: String) -> ([Item], Error?)
}

public protocol AdminOrderInteractor {
    func add(userId: String, orderId: String, itemId: String) -> Error?
}

extension UseCase.OrderInteractor: OrderInteractor {}
extension UseCase.AdminOrderInteractor: AdminOrderInteractor {}

public struct WebServiceHandler {
    public let orderInteractor: OrderInteractor 
    public init(orderInteractor: OrderInteractor) {
	self.orderInteractor = orderInteractor
    }
}

extension WebServiceHandler {
    public func showItems(request: RouterRequest, response: RouterResponse) {
	let userId = request.queryParameters["userId"] ?? ""
	let orderId = request.queryParameters["orderId"] ?? ""
	let (items, error) = orderInteractor.items(userId: userId, orderId: orderId)
	if let error = error {
	    response.send("error: \(error)") 
	    return
	}
	for item in items {
	    response.send("item | id: \(item.id) | name: \(item.name) | value: \(item.value)\n")
	}
    }

    public func addItem(request: RouterRequest, response: RouterResponse) {
	let userId = request.queryParameters["userId"] ?? ""
	let orderId = request.queryParameters["orderId"] ?? ""
	let itemId = request.queryParameters["itemId"] ?? ""
	
	if let error = orderInteractor.add(userId: userId, orderId: orderId, itemId: itemId) {
	  response.send("error: \(error)") 
	  return
	}
	response.send("add success")
    }
}

public struct AdminWebServiceHandler {
    public let adminOrderInteractor: AdminOrderInteractor 
    public init(adminOrderInteractor: AdminOrderInteractor) {
	self.adminOrderInteractor = adminOrderInteractor
    }
}

extension AdminWebServiceHandler {
    public func addItem(request: RouterRequest, response: RouterResponse) {
	let userId = request.queryParameters["userId"] ?? ""
	let orderId = request.queryParameters["orderId"] ?? ""
	let itemId = request.queryParameters["itemId"] ?? ""
	
	if let error = adminOrderInteractor.add(userId: userId, orderId: orderId, itemId: itemId) {
	  response.send("error: \(error)") 
	  return
	}
	response.send("add success")
    }
}
