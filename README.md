# Uber
Final project iOS Uber application

## Team
Eric Ngo  
Ting Yin (Emma)  

## Milestone 1

## Milestone 2
### proposal
This application is a simplified taxi hailing interface.

#### Must have features
1. Users shall be able to sign up as rider/driver. (done)  
2. Users shall be able to log in. (done)  
3. Users shall be able to log out. (done)  
4. Riders shall be able to see their location on the map. (done)  
5. Riders shall be able to hail a ride. (done)  
6. Riders shall be able to cancel request to hail a ride. (done)  
7. Riders shall be able to see driver's live location and distance. (done)  
8. Drivers shall be able to see ride requests and their distances. (done)  
9. Drivers shall be able to select a ride request and view rider location (done)  
10. Drivers shall be able to accept a ride request. (done)  
11. Drivers shall be able to route to the location of their accepted request. (done)  


#### Nice to have features
1. Users shall login with google account. (in-progress)
2. Riders shall be able to rate each other. (done)  
3. Users shall be able to create and view profile pics. (done)
4. Riders shall receive push notifications after their request is accepted. (blocker. must be paid apple developer)

## Milestone 3
### Prototype - see file "Milestone 3 prototype" in repo
### Assign owners for features
1. User Auth - Ting
2. Rider view - Eric
3. Driver view - Eric
4. Profile image - Ting
5. Google login - Ting
6. rating - Eric

## Attribution
The basic features are from The Complete iOS 12 & Swift Developer Course. https://www.udemy.com/course/ios-12-developer-course/ <br />
We modified the code to improve usability and added new features like uploading and displaying profile images, and giving and receiving ratings.


## Installation

```bash
pod install
```

## Execution
The expected execution flow is demonstrated in our demo. Please visit: https://drive.google.com/file/d/1EDCC6PpWetu2ihzgfPU3BiqaB9Tb28L0/view?usp=sharing to view our submission.  
Using simulators, sign up as a rider OR login with credentials: (email,password)=(rider@gmail.com,123456).  
Sign up as a driver OR login with credentials (driver@gmail.com,123456).  
As a rider, call a taxi for pickup.  
As a driver, accept rider's call for pickup.  
As driver, you can navigate to the rider.  
As driver, once you finish navigating, you can Complete the Ride. You can then accept another ride.  
As a rider, once ride is complete, you can rate the driver.   
As a driver, you can see your rating in your profile page.  

## Notes
We have attempted to use google authentication to remove the extra step of having to create a new account and instead have a IdP solution. Unfortunately that feature was not fully implemented.
