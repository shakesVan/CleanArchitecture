import UseCase
import Kitura

public protocol OrderInteractor {
    func items(userId: String, orderId: String) -> ([Item], Error?)
    func add(userId: String, orderId: String, itemId: String) -> Error?
}

extension UseCase.OrderInteractor: OrderInteractor {}

public struct WebserviceHandler {
    public let orderInteractor: OrderInteractor 
    public init(orderInteractor: OrderInteractor) {
	self.orderInteractor = orderInteractor
    }
}

extension WebserviceHandler {
    public func showOrder(req: RouterRequest, res: RouterResponse) {
        let userId = req.queryParameters["userId"] ?? ""
        let orderId = req.queryParameters["orderId"] ?? ""
        let (items,_) = orderInteractor.items(userId: userId, orderId: orderId)
        for item in items {
            res.send("item id: \(item.id)\n")
            res.send("item name: \(item.name)\n")
            res.send("item value: \(item.value)\n")
        }
    }
}
