This project is meant to simulate an app that finds businesses near a user and provides coupon deals for those businesses.  
 
Since the purpose of this project was for learning how to implement a backend into an iOS application, the coupon information is intentionally retrieved from a remote relational database that I created, as opposed to a third-party API. 

Thanks to this project I was able to learn how to use Azure cloud computing services to create an instance of a virtual machine, a server, and use them in conjunction with the iOS app to retrieve data. 

The data is retrieved from the database by sending POST requests from the couponApp to a Node.js project in the virtual machine. The latter subsequently connects to an Azure MySQL server and sends queries to it. 

For the best testing results, please set the following custom location coordinates on the Xcode Simulator: latitude: 28.6037018, longitude: -81.199104 .

