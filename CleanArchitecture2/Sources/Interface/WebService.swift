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
	let (items, _) = orderInteractor.items(userId: userId, orderId: orderId)
	_ = items.map {
	    response.send("item: \($0.id) | \($0.name) | \($0.value)")
	}
	print(items)
    } 
}
