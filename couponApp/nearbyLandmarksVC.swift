
import SwiftUI
import UIKit
import CoreLocation
import MapKit
import Contacts
import Foundation


class nearbyLandmarksVC: UIViewController {
    
    let menuButton = UIButton()
    //let profileButton = UIButton()
    var activityIndicator : UIActivityIndicatorView?
    let table = UITableView()
    var landmarks : [Landmark] = []
    let currentCatLabel = UILabel()
    
    var messageLabel : UILabel?

    let locationManager = CLLocationManager()
    var currentLocation: CLLocation?{
            didSet {
                 performSearch("Store")
            }
        }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        view.backgroundColor = UIColor.systemBackground
        configureLocationManager()
        configureUI()

    }
    
    func configureUI(){
        
//        configureProfileButton()
        configureMenuButton()
        configureCurrentCatLabel()
        configureTableView()
        configureActivityView() // do call this before configureTableView() or the table will hide the indicator view

    }
    
    func configureMenuButton(){
        
        menuButton.translatesAutoresizingMaskIntoConstraints = false
        
        view.addSubview(menuButton)
        
        menuButton.layer.cornerRadius = 10
                
        let menuImage = UIImage(named: "filterImage")
        
        menuButton.setImage(menuImage, for: .normal)
        
        menuButton.clipsToBounds = true // keeps image from rendering outside the button
        
        menuButton.menu = createMenu()
        
        menuButton.showsMenuAsPrimaryAction = true // Allows the pop up menu to display when the button is selected.
        
        NSLayoutConstraint.activate([
            
            menuButton.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -10),
            menuButton.topAnchor.constraint(equalTo: view.topAnchor, constant: 80),
            menuButton.heightAnchor.constraint(equalToConstant: 50),
            menuButton.widthAnchor.constraint(equalToConstant: 50)
        ])
        
    }
    
//    func configureProfileButton(){
//        
//        profileButton.translatesAutoresizingMaskIntoConstraints = false
//        
//        view.addSubview(profileButton)
//        
//        profileButton.setTitle("Show Profile", for: .normal)
//        profileButton.setTitleColor(UIColor.systemBlue, for: .normal) // Won't display if no color is defined
//
//        profileButton.titleLabel?.font = UIFont.systemFont(ofSize: 16 , weight: UIFont.Weight.bold)
//        
//        profileButton.addTarget(self, action: #selector(profileButtonTouch), for: UIControl.Event.touchUpInside)
//
//        NSLayoutConstraint.activate([
//            
//            profileButton.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 10),
//            profileButton.topAnchor.constraint(equalTo: view.topAnchor, constant: 80),
//            profileButton.heightAnchor.constraint(equalToConstant: 50),
//            profileButton.widthAnchor.constraint(equalToConstant: 100)
//        ])
//        
//    }
    
//    @objc func profileButtonTouch()
//    {
//        let nextVC = ProfileView()
//        
//        let hostingController = UIHostingController(rootView: nextVC) // we need to use this wrapper class for SwiftUI views to pass it to the nav. controller.
//        
//        navigationController?.pushViewController(hostingController, animated: true)
//        
//        /*
//         
//         if the next vc was a UIKit VC, we would not create an instance of a hosting controller and just push and instance it to the nav. controller:
//         
//             @objc func didTap() {
//                 let nextVC = someUIKitVC()
//                 navigationController?.pushViewController(nextVC, animated: true)
//             }
//         
//          */
//        
//    }
    
    
    func createMenu()-> UIMenu{
        
        let actions = createActions()
        
        let menu = UIMenu(title: "Categories" , children: actions)
        
        
        return menu
    
    }
    
    func createActions() -> [UIAction]{
        
        
        let restaurantFilterAction  = UIAction(title: "Restaurant" , handler: { _ in self.didTap("Restaurant")})
        let cafeFilterAction = UIAction(title: "Cafe", handler: {_ in self.didTap("Cafe")})
        let foodFilterAction = UIAction(title: "Food Market", handler: {_ in self.didTap("Food Market")})
        let pharmacyFilterAction = UIAction(title: "Pharmacy", handler: {_ in self.didTap("Pharmacy")})
        let wineryFilterAction = UIAction(title: "Winery", handler: {_ in self.didTap("Winery")})
        let bakeryFilterAction = UIAction(title: "Bakery", handler: {_ in self.didTap("Bakery")})
        let defaultFilterAction  = UIAction(title: "Store (Default)" , handler: { _ in self.didTap("Store")})
        
        let menuItems : [UIAction] = [restaurantFilterAction,cafeFilterAction,foodFilterAction,pharmacyFilterAction,wineryFilterAction,bakeryFilterAction,defaultFilterAction]
        
        return menuItems
    }
    
    @objc func didTap(_ categoryType : String){
        
        performSearch(categoryType)
        
    }
    
    func configureActivityView(){
        
        let indicator = UIActivityIndicatorView(style: UIActivityIndicatorView.Style.large)
        
        view.addSubview(indicator)
        indicator.translatesAutoresizingMaskIntoConstraints = false
        indicator.hidesWhenStopped = true
        
        NSLayoutConstraint.activate([
            indicator.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            indicator.centerYAnchor.constraint(equalTo: view.centerYAnchor)
        
        ])
        
        activityIndicator = indicator
        
        
    }
    
    func configureCurrentCatLabel(){
        
        view.addSubview(currentCatLabel)
        currentCatLabel.translatesAutoresizingMaskIntoConstraints = false
        currentCatLabel.font = UIFont.systemFont(ofSize: 20, weight: UIFont.Weight.bold)
        currentCatLabel.textAlignment = .center

        
        NSLayoutConstraint.activate([
        
            currentCatLabel.topAnchor.constraint(equalTo: menuButton.bottomAnchor),
            currentCatLabel.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            currentCatLabel.heightAnchor.constraint(equalToConstant: 50),
            currentCatLabel.widthAnchor.constraint(equalToConstant: 350)
        
        ])
        
    }
    
    // Used to display a popup to inform user that no coupon have been found. Usually occours if Apple API is having issues.
    
    private func showMessageLabel(_ message : String){
        
        if messageLabel == nil { // this just allows us to reuse this method for other content.
            
            let label = UILabel()
            
            view.addSubview(label)
            label.translatesAutoresizingMaskIntoConstraints = false
            label.backgroundColor = UIColor.systemBackground
            label.text = message
            label.font = UIFont.systemFont(ofSize: 18, weight: UIFont.Weight.regular)
            label.textColor = UIColor.systemGray
            label.textAlignment = .center
            
            NSLayoutConstraint.activate([
                
                label.centerXAnchor.constraint(equalTo: view.centerXAnchor),
                label.centerYAnchor.constraint(equalTo: view.centerYAnchor),
                label.widthAnchor.constraint(equalToConstant: 350)
                
            ])
            
            messageLabel = label
            
        }
        
        else{
            
            messageLabel?.text = message
            
        }
        
        
    }

    
    
    func configureTableView(){
        
        view.addSubview(table)
        
        table.translatesAutoresizingMaskIntoConstraints = false
        
        table.delegate = self
        table.dataSource = self
        
        table.register(SelectableTextCell.self, forCellReuseIdentifier: "SelectableTextCell") //register the custom cell for reuse
        
        table.rowHeight = UITableView.automaticDimension

        NSLayoutConstraint.activate([
            
           table.topAnchor.constraint(equalTo: currentCatLabel.bottomAnchor ,constant: 15),
           table.leftAnchor.constraint(equalTo: view.leftAnchor),
           table.bottomAnchor.constraint(equalTo: view.bottomAnchor),
           table.rightAnchor.constraint(equalTo: view.rightAnchor)
        
        ])
        
        
    }
    
}

class SelectableTextCell: UITableViewCell {
    
    let textView = UITextView()
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        configureTextView()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func configureTextView() {
        
        contentView.addSubview(textView)
        
        textView.translatesAutoresizingMaskIntoConstraints = false
        textView.font = .systemFont(ofSize: 16, weight: .regular)
        textView.textColor = UIColor.black
        textView.backgroundColor = UIColor.systemBackground
        textView.isScrollEnabled = false
        textView.isEditable = false
        textView.isSelectable = true
        textView.isUserInteractionEnabled = true
        textView.dataDetectorTypes = [] //property specifies the types of data (phone numbers,links,etc.) that should be converted to URLs; empty array bc we don't want any.
        
        NSLayoutConstraint.activate([
            textView.topAnchor.constraint(equalTo: contentView.topAnchor),
            textView.leftAnchor.constraint(equalTo: contentView.leftAnchor, constant: 15),
            textView.bottomAnchor.constraint(equalTo: contentView.bottomAnchor),
            textView.rightAnchor.constraint(equalTo: contentView.rightAnchor)
        ])
    }
}

extension nearbyLandmarksVC: UITableViewDelegate, UITableViewDataSource {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return landmarks.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        if let cell = tableView.dequeueReusableCell(withIdentifier: "SelectableTextCell", for: indexPath) as? SelectableTextCell {
            
            let landmark = landmarks[indexPath.row] // instantiating a landmark so we can populate the corresponding cell with the desired data.
            
            //creating strings with attributes for styling.
            
            let name = NSMutableAttributedString(string : "\(landmark.name)\n")
            let address = NSMutableAttributedString(string: "\(landmark.address)\n")
            let discount = NSMutableAttributedString(string: "Discount: \(landmark.discount)%\n")
            let code = NSMutableAttributedString(string: "Coupon Code: \(landmark.code)\n")
            
            
            let largeBoldFont = UIFont.systemFont(ofSize : 16 , weight : .bold)
            let regularFont = UIFont.systemFont(ofSize : 14 , weight : .regular)
            let regularBoldFont = UIFont.systemFont(ofSize : 14 , weight : .bold)
            let codeColor = UIColor(red : 112/255.0 , green : 197/255.0 , blue: 111/255.0 , alpha : 1)
            
            name.addAttribute(.font,value : largeBoldFont , range: NSRange(location: 0, length: name.length))
            address.addAttribute(.font,value : regularFont, range: NSRange(location: 0, length: address.length))
            discount.addAttribute(.font,value : regularBoldFont, range: NSRange(location: 0, length: discount.length))
            code.addAttribute(.font,value : regularBoldFont, range: NSRange(location: 0, length: code.length))
            code.addAttribute(.foregroundColor,value : codeColor, range: NSRange(location: 0, length: code.length))
            
            let attributedText = NSMutableAttributedString()
            
            attributedText.append(name)
            attributedText.append(address)
            attributedText.append(discount)
            attributedText.append(code)
            
            cell.textView.attributedText = attributedText
            
//            var text = ""
//
//                                text += landmark.name + "\n"
//
//                                text += landmark.address + "\n"
//
//                                text += "Coupon Code \(landmark.code)" + "\n"
//
//                                text += "Discount: \(landmark.discount)%"
//
//                                 
//
//                        cell.textView.text = text

            cell.textLabel?.numberOfLines = 0 // Allow multi-line text
            
            return cell
            
        } else {
            fatalError("Failed to dequeue SelectableTextCell")
            
        }
    }
    
}

// Model that accepts coupon info from database

struct CouponResponse: Codable {
    let code: String
    let discount: Int
}

// Creating the model that accepts the landmark data from our search and is used to populate the UITableView


struct Landmark{
    
    var name : String
    var address : String
    var code : String
    var discount : Int
    
    
}

func returnCat(_ selection : String) -> [MKPointOfInterestCategory]{
    
    var categories : [MKPointOfInterestCategory] = []
    
    switch selection{
        
    case "Bakery":
        
        categories.append(MKPointOfInterestCategory.bakery)
        return categories
        
    case "Brewery":
        
        categories.append(MKPointOfInterestCategory.brewery)
        return categories
        
    case "Cafe":
        
        categories.append(MKPointOfInterestCategory.cafe)
        return categories
        
    case "Food Market":
        
        categories.append(MKPointOfInterestCategory.foodMarket)
        return categories
        
    case "Pharmacy":
        
        categories.append(MKPointOfInterestCategory.pharmacy)
        return categories
        
    case "Restaurant":
        
        categories.append(MKPointOfInterestCategory.restaurant)
        return categories
        
    case "Store":
        
        categories.append(MKPointOfInterestCategory.store)
        return categories
        
    case "Winery":
        
        categories.append(MKPointOfInterestCategory.winery)
        return categories
    
    default:
        
        categories = [.bakery,.brewery,.cafe,.foodMarket,.pharmacy,.restaurant,.store,.winery]
        return categories
        
        
    }
    
    
}


// need to fix code so that it updates the location when the user changes location.

extension nearbyLandmarksVC : CLLocationManagerDelegate{
    
    
    func configureLocationManager() {
        
            locationManager.delegate = self
            locationManager.desiredAccuracy = kCLLocationAccuracyBest
            locationManager.requestWhenInUseAuthorization()
                    
        }
    
    // The following checks whether the user changed the authorization of the app in order to start collecting the location information.
    
    func locationManager(_ manager: CLLocationManager, didChangeAuthorization status: CLAuthorizationStatus) {
            if status == .authorizedWhenInUse || status == .authorizedAlways {
                
                // This start collecting the location data. It creates a variable called "locations" which stores an array of locations ([CLLocation]);
                // It then passes this variable to the next location manager delegate function.
                
                locationManager.startUpdatingLocation()
            }
        }

        func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
            if let location = locations.last { // this allows us to get the latest location of the user and pass it to our currentLocation variable.
                currentLocation = location
                locationManager.stopUpdatingLocation() // once we get their location, we stop gathering more info.
            }
        }
    
    // Function to get the coupon details from the server:
    
//    func fetchCoupon(tableName: String, name: String, completion: @escaping (CouponResponse?) -> Void) {
//        guard let url = URL(string: "https://trustedcertdomain.xyz:3000/getCoupon") else {
//            completion(nil)
//            return
//        }
//        
//        var request = URLRequest(url: url)
//        request.httpMethod = "POST"
//        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
//        
//        let json: [String: Any] = ["table": tableName, "name": name]
//        let jsonData = try? JSONSerialization.data(withJSONObject: json)
//        request.httpBody = jsonData
//        
//        let task = URLSession.shared.dataTask(with: request) { data, response, error in
//            guard let data = data, error == nil else {
//                print("Request error: \(error?.localizedDescription ?? "Unknown error")")
//                completion(nil)
//                return
//            }
//            
//            if let jsonString = String(data: data, encoding: .utf8) {
//                print("Received JSON: \(jsonString)")
//            }
//            
//            do {
//                let couponResponse = try JSONDecoder().decode(CouponResponse.self, from: data)
//                completion(couponResponse)
//            } catch {
//                print("Failed to decode JSON: \(error.localizedDescription)")
//                completion(nil)
//            }
//        }
//        
//        task.resume()
//    }
    
    func fetchCoupon(tableName: String, name: String, completion: @escaping (CouponResponse?) -> Void) {
        guard let url = URL(string: "https://trustedcertdomain.xyz:3000/getCoupon") else {
            completion(nil)
            return
        }
        
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type") // Important for the Express bodyParser middleware function so that it can parse the JSON request object into a JS object
        
        let json: [String: Any] = ["table": tableName, "name": name]
        let jsonData = try? JSONSerialization.data(withJSONObject: json)
        request.httpBody = jsonData
        
        let task = URLSession.shared.dataTask(with: request) { data, response, error in
            guard let data = data, error == nil else {
                print("Request error: \(error?.localizedDescription ?? "Unknown error")")
                completion(nil)
                return
            }
            
            do {
                let couponResponses = try JSONDecoder().decode([CouponResponse].self, from: data)
                let firstCoupon = couponResponses.first // Extract the first coupon from the array
                completion(firstCoupon)
            } catch {
                print("Failed to decode JSON: \(error.localizedDescription)")
                completion(nil)
            }
        }
        
        task.resume()
    }
    
    
    func performSearch(_ query: String) {
        
        activityIndicator?.startAnimating()
        
        currentCatLabel.text = "\(query) Coupons"
                
        messageLabel?.removeFromSuperview()
        messageLabel = nil
        
        guard let location = currentLocation
        else {
            print("Current location is not available.")
            activityIndicator?.stopAnimating()
            return
        }
        
        let request = MKLocalSearch.Request()
        
        request.naturalLanguageQuery = query
    
        let region = MKCoordinateRegion(center: location.coordinate, latitudinalMeters: 1000, longitudinalMeters: 1000) // these last two parameters specify the distance from the user we want to search for.
        
        request.region = region
        
        let search = MKLocalSearch(request: request)
        
//casting response as a weak reference so that we can deallocate the VC even when data is being fetched for the response object:
        
           search.start { [weak self] response, error in // these are the parameters of the closure that are passed to it once the async. operation in concluded.
               guard let strongSelf = self else { return }// guards against self = nil and creates a reference to self called strongSelf.
               if let error = error {
                   print("Search error: \(error.localizedDescription)")
                   strongSelf.activityIndicator?.stopAnimating()
                   return
               }
               guard let response = response, !response.mapItems.isEmpty else {
                   print("No results were found.")
                   strongSelf.activityIndicator?.stopAnimating()

                   return
               }
            
            // Filtering mapItems and returning
            
            let categories = returnCat(query)
    
            
            let filteredItems = response.mapItems.filter { item in
                
                // .pointOfInterestCategory is a property of .mapItems; it returns false if it's set to nil for that particular item
                
                    guard let category = item.pointOfInterestCategory else {
                        return false }
                
                // If it has a value, we assign it to the "category" variable and use it to check whether it's in our previously defined "categories"
                // array containing the categories we're looking for; it returns true if it is present in the array and added as an item to the
                // filteredItems array, which is our filtered version of mapItems.
                
                    return categories.contains(category)
                }
               
               strongSelf.landmarks.removeAll() // clearing all the old items from the model instance so that we only load the table with new data.

            
            // .placemark = object containing physical location information.
               
               
               if !filteredItems.isEmpty{
                   
                   var newLandmarks: [Landmark] = []
                   let group = DispatchGroup() // Create a DispatchGroup
                   
                   for item in filteredItems {
                       
                               if let name = item.name {
                                   
                                   group.enter() // Enter the group before starting an async task
                                   
                                   strongSelf.fetchCoupon(tableName: query, name: name) { coupon in
                                       
                                       if let coupon = coupon {
                                           let address = CNPostalAddressFormatter.string(from: item.placemark.postalAddress!, style: .mailingAddress)
                                           let landmark = Landmark(name: name, address: address, code: coupon.code, discount: coupon.discount)
                                           newLandmarks.append(landmark)
                                           print(landmark.name , landmark.code , landmark.discount)
                                       }
                                       else {
                                           
                                           print("Failed to fetch coupon for store: \(name)")
                                       }
                                       
                                       group.leave() // Leave the group when the async task is done
                                       
                                       
                                   }
                               }
                                
                            
                           }
                           
                           group.notify(queue: .main) { // Notify when all async tasks are done
                               strongSelf.landmarks = newLandmarks
                               strongSelf.activityIndicator?.stopAnimating()
                               strongSelf.table.reloadData()
                               
                               if newLandmarks.isEmpty{
                                   
                                   strongSelf.showMessageLabel("No \(query) Coupons Found ")
                                   
                               }
                           }
                       }

               else {
                   
                   strongSelf.activityIndicator?.stopAnimating()
                   strongSelf.table.reloadData()
                   strongSelf.showMessageLabel("No \(query) Coupons Found ")
                   
               }
            
        }
    }

}
