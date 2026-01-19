CREATE DATABASE quanlybanhang;
USE quanlybanhang;

CREATE TABLE Customers(
	customer_id int primary key auto_increment,
    customer_name varchar(100) not null,
    phone varchar(20) unique not null,
    address varchar(255)
);

CREATE TABLE Products(
	product_id int primary key auto_increment,
    product_name varchar(100) not null unique,
    price decimal(10,2) not null,
    quantity int not null check(quantity >= 0),
    category varchar(50) not null
);

CREATE TABLE Employees(
	employee_id int primary key auto_increment,
    employee_name varchar(100) not null,
    birthday date,
    position varchar(50) not null,
    salary decimal(10,2) not null,
    revenue decimal(10,2) default 0
);

CREATE TABLE Orders(
	order_id int primary key auto_increment,
    customer_id int,
    employee_id int,
    order_date datetime default current_timestamp,
    total_amount decimal(10,2) default 0,
    foreign key (customer_id) references Customers(customer_id),
    foreign key (employee_id) references Employees(employee_id)
);

CREATE TABLE OrderDetails(
	order_detail_id int primary key auto_increment,
    order_id int,
    product_id int,
    quantity int not null check(quantity>0),
    unit_price decimal(10,2) not null,
    foreign key (order_id) references Orders(order_id),
    foreign key (product_id) references Products(product_id)
);

-- Phần I
-- Câu 3.1: Thêm cột email có kiểu dữ liệu varchar(100) not null unique vào bảng Customers
ALTER TABLE Customers ADD email VARCHAR(100) NOT NULL UNIQUE;

-- Câu 3.2: Xóa cột ngày sinh ra khỏi bảng Employees
ALTER TABLE Employees DROP COLUMN birthday;

-- Phần II
-- Câu 4: Chèn dữ liệu
INSERT INTO Customers(customer_name, email, phone, address) VALUES
('Nguyen Van A','a@gmail.com','0901111111','Ha Noi'),
('Tran Thi B','b@gmail.com','0902222222','Hai Phong'),
('Le Van C','c@gmail.com','0903333333','Da Nang'),
('Pham Thi D','d@gmail.com','0904444444','HCM'),
('Hoang Van E','e@gmail.com','0905555555','Can Tho');

INSERT INTO Products(product_name, price, quantity, category) VALUES
('Laptop HP',1200,50,'Laptop'),
('Iphone 15',1500,80,'Phone'),
('Chuột Logitech',25,300,'Accessory'),
('Bàn phím cơ',80,200,'Accessory'),
('Tai nghe Sony',150,120,'Accessory');

INSERT INTO Employees(employee_name, position, salary) VALUES
('Nguyen Minh','Manager',2000),
('Tran Long','Sales',1200),
('Le An','Sales',1100),
('Pham Hoa','Sales',1300),
('Vo Tuan','Support',1000);

INSERT INTO Orders(customer_id, employee_id, total_amount) VALUES
(1,2,0),
(2,3,0),
(3,4,0),
(1,2,0),
(4,5,0);

INSERT INTO OrderDetails(order_id, product_id, quantity, unit_price) VALUES
(1,1,2,1200),
(1,3,5,25),
(2,2,1,1500),
(3,4,3,80),
(4,5,10,150);

-- Câu 5.1: Lấy danh sách tất cả khách hàng từ bảng Customers. Thông tin gồm : mã khách hàng, tên khách hàng, email, số điện thoại và địa chỉ
SELECT customer_id, customer_name, email, phone, address FROM Customers;

-- Câu 5.2: Sửa thông tin của sản phẩm có product_id = 1 theo yêu cầu : product_name= “Laptop Dell XPS” và price = 99.99
UPDATE Products
SET product_name = 'Laptop Dell XPS', price = 99.99
WHERE product_id = 1;

-- Câu 5.3: Lấy thông tin những đơn đặt hàng gồm : mã đơn hàng, tên khách hàng, tên nhân viên, tổng tiền và ngày đặt hàng
SELECT o.order_id, c.customer_name, e.employee_name, o.total_amount, o.order_date
FROM Orders o
JOIN Customers c ON o.customer_id = c.customer_id
JOIN Employees e ON o.employee_id = e.employee_id;

-- Câu 6.1: Đếm số lượng đơn hàng của mỗi khách hàng. Thông tin gồm : mã khách hàng, tên khách hàng, tổng số đơn
SELECT c.customer_id, c.customer_name, COUNT(o.order_id) AS total_orders
FROM Customers c
LEFT JOIN Orders o ON c.customer_id = o.customer_id
GROUP BY c.customer_id, c.customer_name;

-- Câu 6.2: Thống kê tổng doanh thu của từng nhân viên trong năm hiện tại. Thông tin gồm : mã nhân viên, tên nhân viên, doanh thu
SELECT e.employee_id, e.employee_name, SUM(o.total_amount) AS revenue
FROM Employees e
JOIN Orders o ON e.employee_id = o.employee_id
WHERE YEAR(o.order_date) = YEAR(CURDATE())
GROUP BY e.employee_id, e.employee_name;

-- Câu 6.3: Thống kê những sản phẩm có số lượng đặt hàng lớn hơn 100 trong tháng hiện tại. 
-- Thông tin gồm : mã sản phẩm, tên sản phẩm, số lượt đặt và sắp xếp theo số lượng giảm dần
SELECT p.product_id, p.product_name, SUM(od.quantity) AS total_quantity
FROM OrderDetails od
JOIN Products p ON od.product_id = p.product_id
JOIN Orders o ON od.order_id = o.order_id
WHERE MONTH(o.order_date) = MONTH(CURDATE()) AND YEAR(o.order_date) = YEAR(CURDATE())
GROUP BY p.product_id, p.product_name
HAVING total_quantity > 100
ORDER BY total_quantity DESC;

-- Câu 7.1: Lấy danh sách khách hàng chưa từng đặt hàng. Thông tin gồm : mã khách hàng và tên khách hàng
SELECT c.customer_id, c.customer_name
FROM Customers c
LEFT JOIN Orders o ON c.customer_id = o.customer_id
WHERE o.order_id IS NULL;

-- Câu 7.2: Lấy danh sách sản phẩm có giá cao hơn giá trung bình của tất cả sản phẩm
SELECT * FROM Products
WHERE price > (SELECT AVG(price) FROM Products);

-- Câu 7.3: Tìm những khách hàng có mức chi tiêu cao nhất. Thông tin gồm : mã khách hàng, tên khách hàng và tổng chi tiêu
SELECT c.customer_id, c.customer_name, SUM(o.total_amount) AS total_spent
FROM Customers c
JOIN Orders o ON c.customer_id = o.customer_id
GROUP BY c.customer_id, c.customer_name
HAVING total_spent = (
    SELECT MAX(total)
    FROM (
        SELECT SUM(total_amount) AS total
        FROM Orders
        GROUP BY customer_id
    ) t
);

-- Câu 8.1: Tạo view có tên view_order_list hiển thị thông tin đơn hàng gồm : mã đơn hàng,
-- tên khách hàng, tên nhân viên, tổng tiền và ngày đặt. Các bản ghi sắp xếp theo thứ tự ngày đặt mới nhất
CREATE VIEW view_order_list AS
SELECT o.order_id, c.customer_name, e.employee_name, o.total_amount, o.order_date
FROM Orders o
JOIN Customers c ON o.customer_id = c.customer_id
JOIN Employees e ON o.employee_id = e.employee_id
ORDER BY o.order_date DESC;

-- Câu 8.2: Tạo view có tên view_order_detail_product hiển thị chi tiết đơn hàng gồm : Mã chi tiết đơn hàng, 
-- tên sản phẩm, số lượng và giá tại thời điểm mua. Thông tin sắp xếp theo số lượng giảm dần
CREATE VIEW view_order_detail_product AS
SELECT od.order_detail_id, p.product_name, od.quantity, od.unit_price
FROM OrderDetails od
JOIN Products p ON od.product_id = p.product_id
ORDER BY od.quantity DESC;

-- Câu 9.1: Tạo thủ tục có tên proc_insert_employee nhận vào các thông tin cần thiết (trừ mã nhân viên và tổng doanh thu) , 
-- thực hiện thêm mới dữ liệu vào bảng nhân viên và trả về mã nhân viên vừa mới thêm
DELIMITER //
CREATE PROCEDURE proc_insert_employee(
    IN p_name VARCHAR(100),
    IN p_position VARCHAR(50),
    IN p_salary DECIMAL(10,2),
    OUT new_id INT
)
BEGIN
    INSERT INTO Employees(employee_name, position, salary)
    VALUES(p_name, p_position, p_salary);
    SET new_id = LAST_INSERT_ID();
END//
DELIMITER ;

-- Câu 9.2: Tạo thủ tục có tên proc_get_orderdetails lọc những chi tiết đơn hàng dựa theo mã đặt hàng
DELIMITER //
CREATE PROCEDURE proc_get_orderdetails(IN p_order_id INT)
BEGIN
    SELECT * FROM OrderDetails
    WHERE order_id = p_order_id;
END//
DELIMITER ;

-- Câu 9.3: Tạo thủ tục có tên proc_cal_total_amount_by_order nhận vào tham số là mã
-- đơn hàng và trả về số lượng loại sản phẩm trong đơn hàng đó
DELIMITER //
CREATE PROCEDURE proc_cal_total_amount_by_order(
    IN p_order_id INT,
    OUT total_products INT
)
BEGIN
    SELECT COUNT(DISTINCT product_id)
    INTO total_products
    FROM OrderDetails
    WHERE order_id = p_order_id;
END//
DELIMITER ;

-- Câu 10: Tạo trigger có tên trigger_after_insert_order_details để tự động cập nhật số lượng
-- sản phẩm trong kho mỗi khi thêm một chi tiết đơn hàng mới. Nếu số lượng trong kho
-- không đủ thì ném ra thông báo lỗi “Số lượng sản phẩm trong kho không đủ” và hủy
-- thao tác chèn.
DELIMITER //
CREATE TRIGGER trigger_after_insert_order_details
BEFORE INSERT ON OrderDetails
FOR EACH ROW
BEGIN
    DECLARE stock INT;

    SELECT quantity INTO stock
    FROM Products
    WHERE product_id = NEW.product_id;

    IF stock < NEW.quantity THEN
        SIGNAL SQLSTATE '45000'
        SET MESSAGE_TEXT = 'Số lượng sản phẩm trong kho không đủ';
    ELSE
        UPDATE Products
        SET quantity = quantity - NEW.quantity
        WHERE product_id = NEW.product_id;
    END IF;
END//
DELIMITER ;

-- Câu 11: Tạo một thủ tục có tên proc_insert_order_details nhận vào tham số là mã đơn hàng, mã sản phẩm, số lượng và giá sản phẩm
DELIMITER //
CREATE PROCEDURE proc_insert_order_details(
    IN p_order_id INT,
    IN p_product_id INT,
    IN p_quantity INT,
    IN p_price DECIMAL(10,2)
)
BEGIN
    DECLARE total DECIMAL(10,2);
    DECLARE cnt INT;

    START TRANSACTION;

    SELECT COUNT(*) INTO cnt
    FROM Orders
    WHERE order_id = p_order_id;

    IF cnt = 0 THEN
        SIGNAL SQLSTATE '45000'
        SET MESSAGE_TEXT = 'không tồn tại mã hóa đơn';
    END IF;

    INSERT INTO OrderDetails(order_id, product_id, quantity, unit_price)
    VALUES(p_order_id, p_product_id, p_quantity, p_price);

    SELECT SUM(quantity * unit_price)
    INTO total
    FROM OrderDetails
    WHERE order_id = p_order_id;

    UPDATE Orders
    SET total_amount = total
    WHERE order_id = p_order_id;

    COMMIT;
END//
DELIMITER ;
