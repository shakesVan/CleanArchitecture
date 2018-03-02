import UseCase
import Kitura

public struct WebServiceHandler {
    public let orderInteractor: OrderUseCase 
    public init(orderInteractor: OrderUseCase) {
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
    public let adminOrderInteractor: AdminOrderUseCase 
    public init(adminOrderInteractor: AdminOrderUseCase) {
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
