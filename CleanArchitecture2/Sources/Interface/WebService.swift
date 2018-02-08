import UseCase
import Kitura

public protocol OrderInteractor {
    func add(userId: String, orderId: String, itemId: String) -> Error?
    func items(userId: String, orderId: String) -> ([Item], Error?)
}

extension UseCase.OrderInteractor: OrderInteractor {}

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
	print(request.queryParameters)
	let (items, error) = orderInteractor.items(userId: userId, orderId: orderId)
	if let error = error {
	    print(error)
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
	print(request.queryParameters)
	
	if let error = orderInteractor.add(userId: userId, orderId: orderId, itemId: itemId) {
	  response.send("error: \(error)") 
	  return
	}
	response.send("add success")
    }
}
