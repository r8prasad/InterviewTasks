typedef enum { CAR, VAN, SUV } car_model;

parameter int REQUEST_INTERVAL = 10;

//class car
class baseCar;
  
  car_model model;	//car model
  int seats;		//number of seats
  int time_rented;	//time for which car would be rented
  
  function new();
    time_rented = 0;
  endfunction  
  
  function void display_properties();
    $display("model: %0s, seats: %0d, time rented: %0d", this.model.name, this.seats, this.time_rented);
  endfunction
  
endclass

//class van
class van extends baseCar;
  
  function new();
    super.new();
    model = VAN;
    seats = 6;
  endfunction
  
endclass

//class car
class car extends baseCar;
  
  function new();
    super.new();
    model = CAR;
    seats = 3;
  endfunction
  
endclass

//class suv
class suv extends baseCar;
  
  function new();
    super.new();
    model = SUV;
    seats = 4;
  endfunction
  
endclass

//factory class
class carFactory;
  
  static function baseCar makeCar(car_model model);
    
    van vanCar;
    car carCar;
    suv suvCar;
    
    case (model)
      CAR: begin
        carCar = new();
        return carCar;
      end
      VAN: begin
        vanCar = new();
        return vanCar;
      end
      SUV: begin
        suvCar = new();
        return suvCar;
      end
      default: begin
        $fatal(1, {"No such car model available: ", model.name});  
      end
    endcase
   
  endfunction
  
endclass

//class taxi company
class taxiCompany #(type T=baseCar);
  
  static T cars_available[$];
  static T cars_busy[$];
  
  
  static function void add_car(car_model model);
    T carToAdd;
    carToAdd = carFactory::makeCar(model);
    cars_available.push_back(carToAdd);
  endfunction
  
  static function void get_car(int people, int time_rented);
   
    //update timing of busy cars
    updateTimingOfBusyCars();
    
    if(cars_available.size() > 0) begin
		allot_car(people, time_rented);
    end
    else begin
      $display("No Cars Available. Try renting out after sometime.");
    end  
  endfunction
  
  local static function void allot_car(int people, int time_rented);
	T carToGet;
    int cars_q[$];
    int alloted_car_i;
  
	  //sort cars_available to get the appropriate cars
      cars_available.sort with (item.seats);
      cars_q = cars_available.find_first_index with (item.seats >= people);
      
	  if(cars_q.size() > 0) begin
		//get car from available cars and remove it from the cars_available queue
      	alloted_car_i = cars_q.pop_front();
      	carToGet = cars_available[alloted_car_i];
      	cars_available.delete(alloted_car_i);
    
		//update car rent timing and push it to cars_busy queue
      	carToGet.time_rented = time_rented;
      	cars_busy.push_back(carToGet);
      
		//print available cars
      	print_available_cars();
  
      end
      else begin
        $display("Cars Available but doesn't have enough seats.");
      end  
  endfunction
  
  
  
  local static function void updateTimingOfBusyCars();
    foreach(cars_busy[i]) begin
      	if(cars_busy[i].time_rented - REQUEST_INTERVAL <= 0) begin
        	cars_busy[i].time_rented = 0;
        	cars_available.push_back(cars_busy[i]);
        	cars_busy.delete(i);
      	end	
      	else begin
        	cars_busy[i].time_rented = cars_busy[i].time_rented - REQUEST_INTERVAL;
      	end  
    end  
  endfunction  
  
  local static function void print_available_cars();
    $display("Cars available:");
    
    foreach(cars_available[i])
      cars_available[i].display_properties();  
  endfunction
  
  local static function void print_busy_cars();
    $display("Cars busy:");
    
    foreach(cars_busy[i])
      cars_busy[i].display_properties();  
  endfunction

endclass

module testbench;
  
  int taxiRequestTime;
  
  initial begin
    //add all cars - 2 Cars, 2 Vans, 1 SUV
    taxiCompany::add_car(CAR);
    taxiCompany::add_car(CAR);
    taxiCompany::add_car(VAN);
    taxiCompany::add_car(VAN);
    taxiCompany::add_car(SUV);
    
	//Total time in which requests are allowed to be made
    taxiRequestTime = $urandom;
    
    sendRequests(taxiRequestTime);
  end
  
  function void sendRequests(int totalTime);
    int people, requestTime;
    
	while(totalTime > 0) begin
      //generate request every 10 min
      people = $urandom_range(1, 6);
      requestTime = $urandom_range(10, 100);//this can be changed
      
	  $display("REQUEST: seats = %0d, request time = %0d", people, requestTime);
      
	  //get available cars based on number of people and rental duration
	  taxiCompany::get_car(people, requestTime);
      
	  totalTime = totalTime - REQUEST_INTERVAL;
    end  
    
  endfunction
  
endmodule