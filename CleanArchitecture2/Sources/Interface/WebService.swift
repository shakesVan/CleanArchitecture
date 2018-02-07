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
	print(userId)
	print(orderId)
	let (items, error) = orderInteractor.items(userId: userId, orderId: orderId)
	if let error = error {
	    print(error)
	    return
	}
	for item in items {
	    response.send("item: \(item.id) | \(item.name) | \(item.value)\n")
	}
	print(items)
    } 
}
