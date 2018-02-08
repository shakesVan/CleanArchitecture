# CleanArchitecture

## 下载
```
git clone https://github.com/xiaoyao250/CleanArchitecture.git
```
## 运行
```
cd CleanArchitecture/CleanArchitecture2/
swift build
./.build/debug/Main
```

## 用例
### 用户添加商品
在浏览器中访问：http://localhost:8081/addItem?userId=40&orderId=60&itemId=104

### 用户查看订单中的商品
在浏览器中访问 http://localhost:8081/orders?userId=40&orderId=60
结果类似是这样：
```
item: 101 | Soap | 4.99
item: 104 | Chair | 43.0
```
### 管理员添加商品
在浏览器中访问 http://localhost:8081/orders?userId=40&orderId=60


