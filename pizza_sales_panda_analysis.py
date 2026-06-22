import pandas as pd

orders = pd.read_csv("C:/Users/hp/Videos/sql projects/pizza sales datasets/orders.csv")

orders_details = pd.read_csv("C:/Users/hp/Videos/sql projects/pizza sales datasets/order_details.csv")

pizzas = pd.read_csv("C:/Users/hp/Videos/sql projects/pizza sales datasets/pizzas.csv")

pizza_types = pd.read_csv("C:/Users/hp/Videos/sql projects/pizza sales datasets/pizza_types.csv")

# Dataset Understanding 
# for orders df
print(orders.head(5))
print(orders.shape)
orders.info()
print(orders.describe())
print(orders.isnull().sum())



# for order details df
print(orders_details.head(5))
print(orders_details.shape)
orders_details.info()
print(orders_details.describe())
print(orders_details.isnull().sum())


# for pizzas df
print(pizzas.head(5))
print(pizzas.shape)
pizzas.info()
print(pizzas.describe())
print(pizzas.isnull().sum())


# for pizzas types df
print(pizza_types.head(5))
print(pizza_types.shape)
pizza_types.info()
print(pizza_types.describe())
print(pizza_types.isnull().sum())


# Dulpicat Row
print("Orders Duplicate Rows:")
print(orders.duplicated().sum())

print("Order Details Duplicate Rows:")
print(orders_details.duplicated().sum())

print("Pizzas Duplicate Rows:")
print(pizzas.duplicated().sum())

print("Pizza Types Duplicate Rows:")
print(pizza_types.duplicated().sum())


# Unique Order Counts
print("Unique Order")
print(orders["order_id"].nunique())

print("Unique Category Num and List")
print(pizza_types["category"].unique())
print(pizza_types["category"].nunique())




pizza_df = (
    orders_details
    .merge(orders,on="order_id",how="inner")
    .merge(pizzas,on="pizza_id",how="inner")
    .merge(pizza_types,on="pizza_type_id",how="inner")
)


print(pizza_df.shape)
print(pizza_df.head(5))


# total price
pizza_df["total_price"] = pizza_df["quantity"] * pizza_df["price"]

pizza_df.info()



# KPI Analysis
total_revenue = round(pizza_df["total_price"].sum(),2)
print(f"Total Revenue: {total_revenue}")

total_orders = pizza_df["order_id"].nunique()
print(f"Total Orders: {total_orders}")


total_pizzas_sold = pizza_df["quantity"].sum()
print(f"Total Pizzas Sold: {total_pizzas_sold}")

avg_order_value = round(
    total_revenue / total_orders,
    2
)
print(f"Average Order Value: ${avg_order_value}")


avg_pizzas_per_order = round(
    total_pizzas_sold / total_orders,
    2
)

print(f"Average Pizzas Per Order: {avg_pizzas_per_order}")



# Product Analysis

# Top 10 Revenue Generating Pizzas
top_10_pizza_by_revenue = (
    pizza_df
    .groupby("name",as_index=False)
    .agg(total_revenue=("total_price","sum"))
    .sort_values("total_revenue",ascending=False)
    .head(10)
)

print(f"Top 10 Revenue Generating Pizzas: \n{top_10_pizza_by_revenue}")

# Bottom 10 Revenue Generating Pizzas
bottom_10_pizza_by_revenue = (
    pizza_df
    .groupby("name",as_index=False)
    .agg(total_revenue=("total_price","sum"))
    .sort_values("total_revenue",ascending=True)
    .head(10)
)
print(f"bottom 10 Revenue Generating Pizzas: \n{bottom_10_pizza_by_revenue}")


# Revenue by Category
revenue_by_category = (
    pizza_df
    .groupby("category",as_index=False)
    .agg(total_revenue=("total_price","sum"))
    .sort_values("total_revenue",ascending=False)
)

print(f"<---Revenue by Category---> \n{revenue_by_category}")



# Revenue by Size
revenue_by_size = (
    pizza_df
    .groupby("size",as_index=False)
    .agg(total_revenue=("total_price","sum"))
    .sort_values("total_revenue",ascending=False)
)

print(f"<---Revenue by Size---> \n{revenue_by_size}")


# Most Sold Pizza
most_sold_pizza = (
    pizza_df
    .groupby("name",as_index=False)
    .agg(total_quantity=("quantity","sum"))
    .nlargest(1,"total_quantity")
)

print(f"<---Most Sold Pizza---> \n{most_sold_pizza}")

# Least Sold Pizza
least_sold_pizza = (
    pizza_df
    .groupby("name",as_index=False)
    .agg(total_quantity=("quantity","sum"))
    .nsmallest(1,"total_quantity")
)

print(f"<---Least Sold Pizza---> \n{least_sold_pizza}")




# Time Analysis

pizza_df["date"] = pd.to_datetime(
    pizza_df["date"],
    format="%d-%m-%Y"
)

pizza_df["time"] = pd.to_datetime(
    pizza_df["time"]
)

# Revenue by Month
pizza_df["month_num"] = pizza_df["date"].dt.month
pizza_df["month"] = pizza_df["date"].dt.month_name()

revenue_by_month = (
    pizza_df
    .groupby(["month_num","month"],as_index=False)
    .agg(total_revenue=("total_price","sum"))
    .sort_values("month_num")
)

print(f"<---Revenue by Month---> \n{revenue_by_month}")


# Revenue by Day of Week
pizza_df["weekday"] = pizza_df["date"].dt.day_name()
revenue_by_weekday = (
    pizza_df
    .groupby("weekday",as_index=False)
    .agg(total_revenue=("total_price","sum"))
)
print(f"<---Revenue by Day of Week---> \n{revenue_by_weekday}")


# Orders by Hour
pizza_df["hour"] = pizza_df["time"].dt.hour

order_by_hour = (
    pizza_df
    .groupby("hour",as_index=False)
    .agg(total_order=("order_id","nunique"))
)
print(f"<---Orders by Hour---> \n{order_by_hour}")


# Peak Revenue Hour
peak_revenue_hour = (
    pizza_df
    .groupby("hour",as_index=False)
    .agg(total_revenue=("total_price","sum"))
    .sort_values("total_revenue",ascending=False)
    .head(5)
)
print(f"<---Peak Revenue Hour---> \n{peak_revenue_hour}")


# Busiest Day
busiest_day = (
    pizza_df
    .groupby("weekday",as_index=False)
    .agg(total_order=("order_id","nunique"))
    .sort_values("total_order",ascending=False)
    .head(1)
)
print(f"<---Busiest Day---> \n{busiest_day}")



# Revenue Contribution Analysis
# Category Revenue Share %

category_revenue = (
    pizza_df
    .groupby("category",as_index=False)
    .agg(total_revenue=("total_price","sum"))
)

category_revenue["percentage_share"] = (
    category_revenue["total_revenue"] * 100
    /
    category_revenue["total_revenue"].sum()
).round(2)

print(category_revenue)


# Size Revenue Share %
size_revenue = (
    pizza_df
    .groupby("size",as_index=False)
    .agg(total_revenue=("total_price","sum"))
)

size_revenue["percentage_share"] = (
    size_revenue["total_revenue"] * 100
    /
    size_revenue["total_revenue"].sum()
).round(2)

print(size_revenue)


# Top 5 Pizza Revenue Contribution %
pizza_revenue = (
    pizza_df
    .groupby("name",as_index=False)
    .agg(total_revenue=("total_price","sum"))
    .sort_values("total_revenue",ascending=False)
)

pizza_revenue["percentage_share"] = (
    pizza_revenue["total_revenue"] * 100
    /
    pizza_revenue["total_revenue"].sum()
).round(2)

print(f"<---Top 5 Pizza Revenue Contribution %---> : \n{pizza_revenue.head(5)}")


# Top 5 Pizza vs Rest of Business
top_5_pizza_revenue = (
    pizza_df
    .groupby("name",as_index=False)
    .agg(total_revenue=("total_price","sum"))
    .sort_values("total_revenue",ascending=False)
    .head(5)
)
total_revenue = pizza_df["total_price"].sum()

top_5_pizza_total_revenue = top_5_pizza_revenue["total_revenue"].sum()

rest_of_total_revenue = (total_revenue - top_5_pizza_total_revenue)


top_5_pizza_percentage = (
    top_5_pizza_total_revenue * 100
    /
    total_revenue
).round(2)   

print(f"Top 5 Pizza %: {top_5_pizza_percentage}")

rest_of_business_percentage = (
    rest_of_total_revenue * 100
    /
    total_revenue
).round(2)

print(f"Rest of Business %: {rest_of_business_percentage}")



# Monthly Growth Analysis
monthly_revenue = (
    pizza_df
    .groupby(["month_num","month"],as_index=False)
    .agg(total_revenue=("total_price","sum"))
    .sort_values("month_num")
)

monthly_revenue["previous_revenue"] = (
    monthly_revenue["total_revenue"].shift(1)
)

monthly_revenue["growth_pct"] = (
    monthly_revenue["total_revenue"].pct_change() * 100
)

print(f"<---Monthly Growth Analysis---> \n{monthly_revenue}")





# Category Performance Analysis
# Highest Revenue
highest_category_revenue = (
    pizza_df
    .groupby("category",as_index=False)
    .agg(total_revenue=("total_price","sum"))
    .nlargest(1,"total_revenue")
)
print(f"<---Category Highest Revenue---> \n{highest_category_revenue}")



#  Highest Quantity Sold
highest_category_quantity = (
    pizza_df
    .groupby("category",as_index=False)
    .agg(total_quantity=("quantity","sum"))
    .nlargest(1,"total_quantity")
)
print(f"<---Highest Category Quantity Sold---> \n{highest_category_quantity}")



# Highest Average Order Value
uniqe_category = pizza_df["category"].nunique()

category_avg_order_value = (
    pizza_df
    .groupby("category",as_index=False)
    .agg(
        total_revenue=("total_price","sum"),
        total_order=("order_id","nunique")
        )
)

category_avg_order_value["avg_order_value"] = (
    category_avg_order_value["total_revenue"]
    /
    category_avg_order_value["total_order"]
).round(2)

print(category_avg_order_value.nlargest(1,"avg_order_value"))



