1. Class baseCar: 
	Base class for vehicles. It has fields model, seats and time_rented.
2. Class "car", "van" and "suv" derive from "baseCar".
3. Class carFactory:
	This class instantiates any of the child class of "baseCar" based on the model.
4. Class taxiCompany:
	This class has methods
		- add_car(car_model model) to add cars in the taxiCompany based on the model
		- get_car(int people, int time_rented) to get car for rental based on number of people and duration of rental
	
	This class has 2 queues (cars_available and cars_busy) to keep a track of the cars rented.
5. module testbench:
	- This module first add cars(2 cars, 2 vans, 1 suv) by calling add_car(car_model model) of taxiCompany.
	- Total time for making requests called "taxiRequestTime" is randomly generated.
	- Requests are generated every 10 min by randomizing number of people(1-6) and request time(10, 100) and calling get_car(int people, int time_rented).
