import Domain
import UseCase
import Interface
import Infrastructure
import Kitura
import SQLite

struct MQLogger: Logger {
    func logger(_ msg: String) {
	print(msg)
    } 
}

func main() {
    let filename = "db.sqlite3"
    let sqliteHandle = SqliteHandler(filename: filename)
    var dbHandlers = [String: DbHandler]()
    dbHandlers["DbItemRepo"] = sqliteHandle
    dbHandlers["DbUserRepo"] = sqliteHandle
    dbHandlers["DbOrderRepo"] = sqliteHandle
    dbHandlers["DbCustomerRepo"] = sqliteHandle
    let itemRepo = DbItemRepo.repo(dbHandlers: dbHandlers)
    let userRepo = DbUserRepo.repo(dbHandlers: dbHandlers)
    let orderRepo = DbOrderRepo.repo(dbHandlers: dbHandlers)
    let logger = MQLogger()
    let orderInteractor = OrderInteractor(itemRepo: itemRepo, userRepo: userRepo, orderRepo: orderRepo, logger: logger)
    let webserviceHandler = WebServiceHandler(orderInteractor: orderInteractor)
    
    let router = Router()
    router.get("/orders") {
	req, res, next in
	webserviceHandler.showItems(request: req, response: res)
	next()
    }

    router.get("/addItem") {
	req, res, next in
	webserviceHandler.addItem(request: req, response: res)
	next()
    }


    let adminOrderInteractor = AdminOrderInteractor(itemRepo: itemRepo, userRepo: userRepo, orderRepo: orderRepo, logger: logger)
    let adminWebserviceHandler = AdminWebServiceHandler(adminOrderInteractor: adminOrderInteractor)
    router.get("/admin/addItem") {
	req, res, next in
	adminWebserviceHandler.addItem(request: req, response: res)
	next()
	
    }

    Kitura.addHTTPServer(onPort: 8081, with: router)
    Kitura.run()
}

func creatTables() {
    let filename = "db.sqlite3"
    do {
	let db = try Connection(filename)
        try db.execute("CREATE TABLE users (id VARCHAR(42), customer_id VARCHAR(42), is_admin BOOL);")

        try db.execute("CREATE TABLE customers (id VARCHAR(42), name VARCHAR(42));")
        try db.execute("CREATE TABLE orders (id VARCHAR(42), customer_id VARCHAR(42));")
        try db.execute("CREATE TABLE items (id VARCHAR(42), name VARCHAR(42), value FLOAT, available BOOL);")
        try db.execute("CREATE TABLE items2orders (item_id VARCHAR(42), order_id VARCHAR(42));")
        try db.execute("INSERT INTO users (id, customer_id, is_admin) VALUES (40, 50, 1);")
        try db.execute("INSERT INTO customers (id, name) VALUES (50, \"John Doe\");")
        try db.execute("INSERT INTO orders (id, customer_id) VALUES (60, 50);")
        try db.execute("INSERT INTO items (id, name, value, available) VALUES (101, \"Soap\", 4.99, 1);")
        try db.execute("INSERT INTO items (id, name, value, available) VALUES (102, \"Fork\", 2.99, 1);")
        try db.execute("INSERT INTO items (id, name, value, available) VALUES (103, \"Bottle\", 6.99, 0);")
        try db.execute("INSERT INTO items (id, name, value, available) VALUES (104, \"Chair\", 43.00, 1);")
        try db.execute("INSERT INTO items2orders (item_id, order_id) VALUES (101, 60);")
        try db.execute("INSERT INTO items2orders (item_id, order_id) VALUES (104, 60);")
    
    } catch let error {
	print(error)
    }
}

main()
//creatTables()

