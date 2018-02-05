# CleanArchitecture
根据The Clean Architecture Go 版本翻译的swift版本
数据库用的是SQLite3
服务端用的是Kitura

##运行
```
cd CleanArchitecture/CleanArchitecture/
swift build
./.build/debug/Main
```
##在浏览器中访问 http://localhost:8080/orders?userId=40&orderId=60
结果应该是：
```
item id: 101
item name: Soap
item value: 4.990000
item id: 104
item name: Chair
item value: 43.000000
```

##可以用下面的 SQL 在 /var/tmp/production.sqlite 中创建一个最小的数据集：
```
CREATE TABLE users (id INTEGER, customer_id INTEGER, is_admin VARCHAR(3));
CREATE TABLE customers (id INTEGER, name VARCHAR(42));
CREATE TABLE orders (id INTEGER, customer_id INTEGER);
CREATE TABLE items (id INTEGER, name VARCHAR(42), value FLOAT, available VARCHAR(3));
CREATE TABLE items2orders (item_id INTEGER, order_id INTEGER);
INSERT INTO users (id, customer_id, is_admin) VALUES (40, 50, "yes");
INSERT INTO customers (id, name) VALUES (50, "John Doe");
INSERT INTO orders (id, customer_id) VALUES (60, 50);
INSERT INTO items (id, name, value, available) VALUES (101, "Soap", 4.99, "yes");
INSERT INTO items (id, name, value, available) VALUES (102, "Fork", 2.99, "yes");
INSERT INTO items (id, name, value, available) VALUES (103, "Bottle", 6.99, "no");
INSERT INTO items (id, name, value, available) VALUES (104, "Chair", 43.00, "yes");
INSERT INTO items2orders (item_id, order_id) VALUES (101, 60);
INSERT INTO items2orders (item_id, order_id) VALUES (104, 60);
```
摘录来自: Uncle Bob. “The Clean Architecture”。 iBooks.
