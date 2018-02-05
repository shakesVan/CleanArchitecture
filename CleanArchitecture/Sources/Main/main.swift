import Entities
import UseCase
import Interface
import Infrastructure
import SQLite
import Kitura

struct MYLogger: Logger {
    public func logger(msg: String) {
        print(msg)
    }
}

func main() {

    let filename = "db.sqlite3"
    let handler = Infrastructure.SqliteHandler(dbfileName: filename)

    var dbHandlers: [String: DbHandler] = [:]
    dbHandlers["DbUserRepo"] = handler
    dbHandlers["DbCustomerRepo"] = handler
    dbHandlers["DbItemRepo"] = handler
    dbHandlers["DbOrderRepo"] = handler

    let userRepo = DbUserRepo.repo(dbHandlers: dbHandlers)
    let itemRepo = DbItemRepo.repo(dbHandlers: dbHandlers)
    let orderRepo = DbOrderRepo.repo(dbHandlers: dbHandlers)

    let logger = MYLogger()

    let orderInteractor = UseCase.OrderInteractor(userRepo: userRepo,
                    itemRepo: itemRepo,
                    orderRepo: orderRepo,
                    logger: logger)
    let webServiceHandler = WebserviceHandler(orderInteractor: orderInteractor)

    
    let router = Router()
    router.get("/orders") {
	request, response, next in
	print(request)
	webServiceHandler.showOrder(req: request, res: response)
	next()
    }
    Kitura.addHTTPServer(onPort: 8080, with: router)
    Kitura.run()

//    let (items, _) = orderInteractor.items(userId: "40", orderId: "60")
//    print(items)

}

func creatTables() {
    let filename = "db.sqlite3"
    let db = try! Connection(filename)
    try! db.execute("CREATE TABLE users (id VARCHAR(42), customer_id VARCHAR(42), is_admin BOOL);")

    try! db.execute("CREATE TABLE customers (id VARCHAR(42), name VARCHAR(42));")
    try! db.execute("CREATE TABLE orders (id VARCHAR(42), customer_id VARCHAR(42));")
    try! db.execute("CREATE TABLE items (id VARCHAR(42), name VARCHAR(42), value FLOAT, available BOOL);")
    try! db.execute("CREATE TABLE items2orders (item_id VARCHAR(42), order_id VARCHAR(42));")
    try! db.execute("INSERT INTO users (id, customer_id, is_admin) VALUES (40, 50, 1);")
    try! db.execute("INSERT INTO customers (id, name) VALUES (50, \"John Doe\");")
    try! db.execute("INSERT INTO orders (id, customer_id) VALUES (60, 50);")
    try! db.execute("INSERT INTO items (id, name, value, available) VALUES (101, \"Soap\", 4.99, 1);")
    try! db.execute("INSERT INTO items (id, name, value, available) VALUES (102, \"Fork\", 2.99, 1);")
    try! db.execute("INSERT INTO items (id, name, value, available) VALUES (103, \"Bottle\", 6.99, 0);")
    try! db.execute("INSERT INTO items (id, name, value, available) VALUES (104, \"Chair\", 43.00, 1);")
    try! db.execute("INSERT INTO items2orders (item_id, order_id) VALUES (101, 60);")
    try! db.execute("INSERT INTO items2orders (item_id, order_id) VALUES (104, 60);")
}

main()
//creatTables()

