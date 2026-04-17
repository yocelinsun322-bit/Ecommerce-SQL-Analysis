-- 模拟数据库
CREATE DATABASE IF NOT EXISTS ecommerce
DEFAULT CHARACTER SET utf8mb4
DEFAULT COLLATE utf8mb4_unicode_ci;
USE ecommerce;

-- 模拟数据表
-- ----------------------------
-- 1. 用户表 user
-- ----------------------------
DROP TABLE IF EXISTS `user`;
CREATE TABLE `user` (
  `global_user_id` varchar(50) NOT NULL,
  `platform_user_id` varchar(50) DEFAULT NULL,
  `platform` varchar(20) DEFAULT NULL,
  `user_name` varchar(50) DEFAULT NULL,
  `gender` varchar(1) DEFAULT NULL,
  `age` int DEFAULT NULL,
  `city` varchar(50) DEFAULT NULL,
  `registration_date` date DEFAULT NULL,
  `phone` varchar(20) DEFAULT NULL,
  `email` varchar(100) DEFAULT NULL,
  `user_level` varchar(20) DEFAULT NULL,
  PRIMARY KEY (`global_user_id`),
  KEY `idx_platform` (`platform`),
  KEY `idx_phone` (`phone`),
  KEY `idx_email` (`email`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

-- ----------------------------
-- 2. 用户行为表 user_behavior
-- ----------------------------
DROP TABLE IF EXISTS `user_behavior`;
CREATE TABLE `user_behavior` (
  `behavior_id` int NOT NULL AUTO_INCREMENT,
  `global_user_id` varchar(50) DEFAULT NULL,
  `global_product_id` varchar(50) DEFAULT NULL,
  `platform` varchar(20) DEFAULT NULL,
  `session_id` varchar(100) DEFAULT NULL,
  `behavior_type` varchar(50) DEFAULT NULL,
  `behavior_time` datetime(6) DEFAULT NULL,
  `duration_seconds` int DEFAULT NULL,
  `page_url` varchar(500) DEFAULT NULL,
  `referrer` varchar(500) DEFAULT NULL,
  `device_type` varchar(50) DEFAULT NULL,
  `app_version` varchar(50) DEFAULT NULL,
  `latitude` decimal(9,6) DEFAULT NULL,
  `longitude` decimal(9,6) DEFAULT NULL,
  `extra_data` longtext,
  PRIMARY KEY (`behavior_id`),
  KEY `idx_global_user_id` (`global_user_id`),
  KEY `idx_platform` (`platform`),
  KEY `idx_behavior_type` (`behavior_type`),
  KEY `idx_behavior_time` (`behavior_time`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

-- ----------------------------
-- 3. 订单主表 order
-- ----------------------------
DROP TABLE IF EXISTS `order`;
CREATE TABLE `order` (
  `order_id` varchar(100) NOT NULL,
  `global_user_id` varchar(50) DEFAULT NULL,
  `platform` varchar(20) DEFAULT NULL,
  `order_time` datetime(6) DEFAULT NULL,
  `payment_time` datetime(6) DEFAULT NULL,
  `payment_method` varchar(50) DEFAULT NULL,
  `shipping_address` longtext,
  `order_status` varchar(50) DEFAULT NULL,
  `total_amount` decimal(12,2) DEFAULT NULL,
  `discount_amount` decimal(10,2) DEFAULT NULL,
  `shipping_fee` decimal(8,2) DEFAULT NULL,
  `tax_amount` decimal(8,2) DEFAULT NULL,
  `promotion_id` varchar(100) DEFAULT NULL,
  `coupon_code` varchar(50) DEFAULT NULL,
  `shipping_method` varchar(50) DEFAULT NULL,
  PRIMARY KEY (`order_id`),
  KEY `idx_global_user_id` (`global_user_id`),
  KEY `idx_platform` (`platform`),
  KEY `idx_order_time` (`order_time`),
  KEY `idx_order_status` (`order_status`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

-- ----------------------------
-- 4. 订单明细表 order_item
-- ----------------------------
DROP TABLE IF EXISTS `order_item`;
CREATE TABLE `order_item` (
  `order_item_id` int NOT NULL AUTO_INCREMENT,
  `order_id` varchar(100) DEFAULT NULL,
  `global_product_id` varchar(50) DEFAULT NULL,
  `quantity` int DEFAULT NULL,
  `unit_price` decimal(10,2) DEFAULT NULL,
  `item_total` decimal(12,2) DEFAULT NULL,
  `sku_info` longtext,
  PRIMARY KEY (`order_item_id`),
  KEY `idx_order_id` (`order_id`),
  KEY `idx_global_product_id` (`global_product_id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

--  导入 user
LOAD DATA INFILE 'C:/ProgramData/MySQL/MySQL Server 8.0/Uploads/user.csv'
INTO TABLE `user`
CHARACTER SET utf8mb4
FIELDS TERMINATED BY ',' 
ENCLOSED BY '"'
LINES TERMINATED BY '\n'
IGNORE 1 ROWS;

-- 导入 user_behavior
LOAD DATA INFILE 'C:/ProgramData/MySQL/MySQL Server 8.0/Uploads/user_behavior.csv'
INTO TABLE `user_behavior`
CHARACTER SET utf8mb4
FIELDS TERMINATED BY ',' 
ENCLOSED BY '"'
LINES TERMINATED BY '\n'
IGNORE 1 ROWS;

-- 导入 order
LOAD DATA INFILE 'C:/ProgramData/MySQL/MySQL Server 8.0/Uploads/order.csv'
INTO TABLE `order`
CHARACTER SET utf8mb4
FIELDS TERMINATED BY ',' 
ENCLOSED BY '"'
LINES TERMINATED BY '\n'
IGNORE 1 ROWS;

-- 导入 order_item
LOAD DATA INFILE 'C:/ProgramData/MySQL/MySQL Server 8.0/Uploads/order_item.csv'
INTO TABLE `order_item`
CHARACTER SET utf8mb4
FIELDS TERMINATED BY ',' 
ENCLOSED BY '"'
LINES TERMINATED BY '\n'
IGNORE 1 ROWS;

-- 一. 数据质量检查与清洗
-- 1. 查看每张表总行数
SELECT 'user' AS table_name, COUNT(*) AS row_count FROM `user`
UNION ALL
SELECT 'user_behavior', COUNT(*) FROM user_behavior
UNION ALL
SELECT 'order', COUNT(*) FROM `order`
UNION ALL
SELECT 'order_item', COUNT(*) FROM order_item;

-- 2. user数据检查
-- 2.1 检查用户ID是否重复
SELECT global_user_id, COUNT(*) AS cnt
FROM `user`
GROUP BY global_user_id
HAVING COUNT(*) > 1;

-- 2.2 检查关键字段空值
SELECT
  COUNT(*) AS total,
  SUM(CASE WHEN global_user_id IS NULL THEN 1 ELSE 0 END) AS null_user_id,
  SUM(CASE WHEN registration_date IS NULL THEN 1 ELSE 0 END) AS null_reg_date,
  SUM(CASE WHEN gender IS NULL THEN 1 ELSE 0 END) AS null_gender,
  SUM(CASE WHEN city IS NULL THEN 1 ELSE 0 END) AS null_city
FROM `user`;

-- 2.3 检查异常年龄
SELECT * FROM `user` WHERE age < 0 OR age > 100;

-- 3. user_behavior检查
-- 3.1 检查空的用户ID/行为类型/行为时间
SELECT
  COUNT(*) AS total,
  SUM(CASE WHEN global_user_id IS NULL THEN 1 ELSE 0 END) AS null_user_id,
  SUM(CASE WHEN behavior_type IS NULL THEN 1 ELSE 0 END) AS null_behavior,
  SUM(CASE WHEN behavior_time IS NULL THEN 1 ELSE 0 END) AS null_time
FROM user_behavior;

-- 3.2 检查不合法的行为类型
SELECT DISTINCT behavior_type FROM user_behavior;

-- 3.3 检查异常的行为时间（未来时间和过早时间）
SELECT * FROM user_behavior
WHERE behavior_time > NOW() OR behavior_time < '2000-01-01';

-- 3.3.1 清理异常时间
DELETE FROM user_behavior
WHERE behavior_time > NOW() OR behavior_time < '2000-01-01';

-- 3.3.2 复检
SELECT * FROM user_behavior
WHERE behavior_time > NOW() OR behavior_time < '2000-01-01';

-- 3.3.3 重建干净的user_behavior
DROP TABLE IF EXISTS clean_behavior;
CREATE TABLE clean_behavior AS
SELECT DISTINCT *
FROM user_behavior
WHERE global_user_id IS NOT NULL
  AND behavior_type IS NOT NULL
  AND behavior_time BETWEEN '2000-01-01' AND NOW();
  
-- 4. order检查
-- 4.1 总订单数 + 空值
SELECT
  COUNT(*) AS total_orders,
  SUM(CASE WHEN order_id IS NULL THEN 1 ELSE 0 END) AS null_order_id,
  SUM(CASE WHEN global_user_id IS NULL THEN 1 ELSE 0 END) AS null_user_id,
  SUM(CASE WHEN order_time IS NULL THEN 1 ELSE 0 END) AS null_order_time
FROM `order`;

-- 4.2 异常金额（负数/0/空）
SELECT * FROM `order`
WHERE total_amount < 0 OR total_amount IS NULL;

-- 4.3. 支付时间早于下单时间（异常订单）
SELECT * FROM `order`
WHERE payment_time IS NOT NULL AND payment_time < order_time;

-- 4.4 订单状态分布
SELECT order_status, COUNT(*) AS cnt
FROM `order`
GROUP BY order_status;

-- 5.order_item检查
-- 5.1 总行数 + 空值/异常数量/价格
SELECT
  COUNT(*) AS total_item,
  SUM(CASE WHEN order_id IS NULL THEN 1 ELSE 0 END) AS null_order_id,
  SUM(CASE WHEN quantity <= 0 THEN 1 ELSE 0 END) AS invalid_quantity,
  SUM(CASE WHEN unit_price < 0 THEN 1 ELSE 0 END) AS invalid_price
FROM order_item;

-- 2. 检查是否有不存在的订单
SELECT DISTINCT order_id FROM order_item
WHERE order_id NOT IN (SELECT order_id FROM `order`);

-- 二. 核心业务指标计算
-- 1. 总用户、总订单、总GMV、总行为量
SELECT
  '总用户数' AS 指标, COUNT(DISTINCT global_user_id) AS 数值 FROM user
UNION ALL
SELECT
  '总订单数', COUNT(DISTINCT order_id) FROM `order`
UNION ALL
SELECT
  '总GMV', SUM(total_amount) FROM `order`
UNION ALL
SELECT
  '总行为数', COUNT(*) FROM clean_behavior
UNION ALL
SELECT
  '支付订单数', COUNT(DISTINCT order_id) FROM `order` WHERE payment_time IS NOT NULL;
  
-- 2. 用户行为漏斗分析
WITH behavior_funnel AS (
  SELECT
    COUNT(DISTINCT CASE WHEN behavior_type = '浏览' THEN global_user_id END) AS 浏览用户数,
    COUNT(DISTINCT CASE WHEN behavior_type = '加购' THEN global_user_id END) AS 加购用户数,
    COUNT(DISTINCT CASE WHEN behavior_type = '下单' THEN global_user_id END) AS 购买用户数
  FROM clean_behavior
)
SELECT
  浏览用户数,
  加购用户数,
  购买用户数,
  ROUND(加购用户数 / 浏览用户数, 3) AS 加购转化率,
  ROUND(购买用户数 / 加购用户数, 3) AS 购买转化率,
  ROUND(购买用户数 / 浏览用户数, 3) AS 整体转化率
FROM behavior_funnel;

-- 3 每日订单 & GMV趋势
SELECT
  DATE(order_time) AS 日期,
  COUNT(DISTINCT order_id) AS 订单数,
  SUM(total_amount) AS 每日GMV,
  AVG(total_amount) AS 客单价
FROM `order`
GROUP BY 日期
ORDER BY 日期;

-- 4. 用户复购率
WITH user_order_count AS (
    SELECT
        global_user_id,
        COUNT(DISTINCT order_id) AS order_cnt
    FROM `order`
    GROUP BY global_user_id
),
user_type AS (
    SELECT
        global_user_id,
        CASE WHEN order_cnt = 1 THEN '仅购买1次'
             WHEN order_cnt >=2 THEN '复购用户'
        END AS user_category
    FROM user_order_count
)
SELECT
    user_category AS 用户类型,
    COUNT(*) AS 用户数量
FROM user_type
GROUP BY user_category;

-- 5 用户画像分析
-- 5.1 性别消费能力
SELECT
    u.gender AS 性别,
    COUNT(DISTINCT u.global_user_id) AS 用户数,
    COUNT(DISTINCT o.order_id) AS 订单数,
    SUM(o.total_amount) AS 总消费,
    AVG(o.total_amount) AS 平均客单价
FROM `user` u
LEFT JOIN `order` o ON u.global_user_id = o.global_user_id
GROUP BY u.gender;

-- 5.2 年龄分段消费
SELECT
    CASE WHEN age < 20 THEN '小于20岁'
         WHEN age BETWEEN 20 AND 29 THEN '20-29岁'
         WHEN age BETWEEN 30 AND 39 THEN '30-39岁'
         ELSE '40岁以上'
    END AS 年龄段,
    COUNT(DISTINCT u.global_user_id) AS 用户数,
    SUM(o.total_amount) AS 消费总额
FROM `user` u
LEFT JOIN `order` o ON u.global_user_id = o.global_user_id
GROUP BY 年龄段
ORDER BY 年龄段;

-- 6. RFM 用户价值分层
WITH rfm_calc AS (
    SELECT
        global_user_id,
        DATEDIFF(NOW(), MAX(order_time)) AS R,
        COUNT(DISTINCT order_id) AS F,
        SUM(total_amount) AS M
    FROM `order`
    GROUP BY global_user_id
),
rfm_level AS (
    SELECT
        *,
        CASE WHEN R <= 30 THEN '高活跃' ELSE '低活跃' END AS R_level,
        CASE WHEN F >= 2 THEN '高频' ELSE '低频' END AS F_level,
        CASE WHEN M >= 100 THEN '高价值' ELSE '低价值' END AS M_level
    FROM rfm_calc
)
SELECT
    CONCAT(R_level,'-',F_level,'-',M_level) AS 用户分层,
    COUNT(*) AS 用户数
FROM rfm_level
GROUP BY 用户分层
ORDER BY 用户数 DESC;

-- 7. 商品销量Top10
SELECT
    order_item_id AS 商品ID,
    SUM(quantity) AS 总销量,
    SUM(quantity * unit_price) AS 商品GMV
FROM order_item
GROUP BY order_item_id
ORDER BY 总销量 DESC
LIMIT 10;

-- 8. 订单支付率
SELECT
    COUNT(DISTINCT order_id) AS 总订单数,
    COUNT(DISTINCT CASE WHEN payment_time IS NOT NULL THEN order_id END) AS 支付订单数,
    ROUND(
        COUNT(DISTINCT CASE WHEN payment_time IS NOT NULL THEN order_id END)
        / COUNT(DISTINCT order_id)
    , 2) AS 支付率
FROM `order`;
