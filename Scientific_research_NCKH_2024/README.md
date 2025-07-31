                         BUILDING A PRICE SUGGESTION MODEL FOR NEWCOMERS ONE-COMMERCE PLATFORMS
I. About:                                  
  
  In the context of an increasingly competitive e-commerce market, optimizing product prices has become a crucial factor. This study proposes a product price suggestion model using Neural Networks, XGBoost, Stacked Regressor, Grid Search, and Simple Regressor models. The results show that the Neural Network machine learning model with 3 hidden layers, XGBoost, Stacked Regressor, Grid Search, and Simple Regressor all yield good forecasting results and performance. The important input parameters for suggesting product prices on e-commerce platforms through machine learning models include brand, rating index, number of products sold index, listed price index, and original price index.        

II. Data:

The study is based on Bright Data's user research dataset collected from the API of Shopee e-commerce platform (https://github.com/luminati-io/Shopee-dataset-samples)

A Shopee dataset sample of over 1000 products. Dataset was extracted using the Bright Data API.

The dataset includes 898 rows and 17 data fields. The variables used in the model are described in Table 1.

Feature -------- Description

product_id:        	Unique identifier for products on Shopee. 

product_name:       Product's Name

variation:       	  Information about product variations

category_id  :  	  Product category classification identifier

brand:          	  Product branding strongly influences purchasing decisions due to brand recognition and customer trust. 

rating:             Average customer rating for a product, an important indicator of product quality.

initial_price:   	  The original or starting price of the product.	

final_price:    	  The current price or final price of the product after any discounts or promotions (which is the target value of the model).	

currency:        	  Currency type.

sold:          	    The number of units sold, which indicates the popularity of the product, plays an important role in predicting price.

status:        	    product status

image:        	    Product image.

flash_sale:    	    Product discount.

vouchers:    	      Coupon.

category:      	    product category

price_to_sold_ratio:	The price-volume ratio (price/volume) is an index that combines price and sales volume, helping to evaluate the value of a product in the market.

III.Theoretical basis:
 
 The study uses the models: Simple Regressor (SR), Grid Search (GS), Stacked Regressor, XGBoost and Neural Network to suggest product prices based on Shopee data collected from APIs. Because it can be said that Shopee is one of the most popular e-commerce platforms in Southeast Asia and Vietnam, with a large transaction volume and rich database. In addition, the Stacked Regressor model combines many models such as XGBoost and Neural Network to achieve the highest accuracy in suggesting selling prices for high-revenue products on Shopee.

IV. Installation $ Requirements:
 - Numpy
 - Pandas
 - Matplotlib
 - Seaborn
 - Scikit - learn for modelling
 - XGBoost for XGBRegressor 
 - Catboost for CatboostRegressor
 - Tensorflow 

V. Result:

  The three models Neural Network (3 hidden layers), Stacked Regressor and Grid Search all give better forecasting results than the other three models. The Neural Network (3 hidden layers) model gives the most accurate forecasting results with test_mae of 1.602, the best among the models without overfitting with moderate configuration (with 3 hidden layers with minimal structure). Stacked Regressor and Grid Search provide stable performance, suitable when technical fine-tuning is needed. It is possible that some independent variables in the model are highly correlated with each other, affecting the performance of the Neural Network with 10 hidden layers, Simple Regressor, Neural Network with 5 hidden layers. Therefore, the Neural Network (3 hidden layers) model can be used to suggest product prices in the next period.

VI. Conclude:

  Machine learning models have been shown to be more effective than traditional statistical models in many different fields, thanks to their superior advantages of not requiring strict data conditions and relationships between independent variables and dependent variables. As a result, machine learning models have wider and more flexible application capabilities. In this study, the Neural Network model with three hidden layers outperformed the Stacked Regressor and Grid Search models in suggesting product prices on the Shopee platform. At the same time, the study identified factors affecting product prices by assessing the importance of features in the regression model. This brings great practical value to stores and e-commerce platforms, helping them accurately assess product price fluctuations and build more effective business strategies.
