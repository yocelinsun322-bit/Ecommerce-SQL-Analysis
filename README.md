## 电商用户行为数据分析 Ecommerce-SQL-Analysis
MySQL电商用户行为数据分析，包含数据清洗、漏斗分析、RFM用户分层等
### 分析流程
1. 建库建表，数据导入
2. 阶段1：数据质量探查、异常值清洗，剔除未来时间脏数据
3. 阶段2：核心业务指标计算
  - 总用户、总订单、总GMV、总行为量
  - 用户行为转化漏斗：浏览→加购→下单→支付
  - 每日GMV趋势统计
  - 用户复购分析
  - 用户画像（性别、年龄维度）
  - RFM用户价值分层
  - 商品销量TOP统计
  - 订单支付率分析
### 数据来源
https://tianchi.aliyun.com/dataset/222889
  -选取order.csv, order_item.csv, user.csv, user_behavior.csv
