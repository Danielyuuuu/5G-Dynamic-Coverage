//
//  ViewController.swift
//  dynamic
//
//  Created by shenglanyu on 3/3/20.
//  Copyright © 2020 shenglanyu. All rights reserved.
//

import UIKit
import CoreLocation
import Firebase
import MapKit

class ViewController: UIViewController, CLLocationManagerDelegate {
    
    let locman = CLLocationManager()
    var location: CLLocation?
    var startTime: Date?
    
    var ref: DatabaseReference!
    
    @IBOutlet weak var latencyLabel: UILabel!
    
    lazy var functions = Functions.functions()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        locman.requestAlwaysAuthorization()
        locman.requestWhenInUseAuthorization()
        ref = Database.database().reference()
    }
    
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {

        guard let loc = locations.last else { return }

        let time = loc.timestamp

        guard var startTime = startTime else {
            self.startTime = time // Saving time of first location, so we could use it to compare later with second location time.
            return //Returning from this function, as at this moment we don't have second location.
        }

        let elapsed = time.timeIntervalSince(startTime) // Calculating time interval between first and second (previously saved) locations timestamps.

        if elapsed > 30 { //If time interval is more than 30 seconds
            print("Upload updated location to server")
            //updateUser(location: loc) //user function which uploads user location or coordinate to server.
            
            functions.httpsCallable("helloWorld").call() { (result, error) in
              if let error = error as NSError? {
                if error.domain == FunctionsErrorDomain {
                  //let code = FunctionsErrorCode(rawValue: error.code)
                  //let message = error.localizedDescription
                  //let details = error.userInfo[FunctionsErrorDetailsKey]
                }
                
              }
              if let text = (result?.data as? String) {
                print(text)
              }
            }
            
            startTime = time //Changing our timestamp of previous location to timestamp of location we already uploaded.

        }
    }
    
    func ping() {
        var currentLocation: CLLocation!
        let now = Date()
        let formatter = DateFormatter()
        formatter.timeZone = TimeZone.current
        formatter.dateFormat = "yyyy-MM-dd HH:mm:ss"
        let dateString = formatter.string(from: now)
        let timer = ParkBenchTimer()
        
        functions.httpsCallable("ping").call() { (result, error) in
          if let error = error as NSError? {
            if error.domain == FunctionsErrorDomain {
              //let code = FunctionsErrorCode(rawValue: error.code)
              //let message = error.localizedDescription
              //let details = error.userInfo[FunctionsErrorDetailsKey]
            }
            
          }
            if ((result?.data as? [String: Any])?["result"] as? String) != nil {
            let elpased = timer.stop()
            
            self.latencyLabel.text = String(elpased)
            
            if
               CLLocationManager.authorizationStatus() == CLAuthorizationStatus.authorizedWhenInUse ||
               CLLocationManager.authorizationStatus() ==  CLAuthorizationStatus.authorizedAlways
            {
                currentLocation = self.locman.location
                print(currentLocation.coordinate.longitude, currentLocation.coordinate.latitude)
                
                self.ref.child("location").child(dateString).setValue(["longitude": currentLocation.coordinate.longitude, "latitude": currentLocation.coordinate.latitude, "latency": elpased]) {
                (error:Error?, ref:DatabaseReference) in
                if let error = error {
                  print("Data could not be saved: \(error).")
                } else {
                  print("Data saved successfully!")
                }
                }
            }
          }
        }
    }

    @IBAction func dealTapped(_ sender: Any) {
        //locationManager(locman)
        ping()
        
        /*
        var currentLocation: CLLocation!
        let now = Date()
        let formatter = DateFormatter()
        formatter.timeZone = TimeZone.current
        formatter.dateFormat = "yyyy-MM-dd HH:mm:ss"
        let dateString = formatter.string(from: now)

        if
           CLLocationManager.authorizationStatus() == CLAuthorizationStatus.authorizedWhenInUse ||
           CLLocationManager.authorizationStatus() ==  CLAuthorizationStatus.authorizedAlways
        {
            currentLocation = locman.location
            print(currentLocation.coordinate.longitude, currentLocation.coordinate.latitude)
            
            ref.child("location").child(dateString).setValue(["longitude": currentLocation.coordinate.longitude, "latitude": currentLocation.coordinate.latitude]) {
              (error:Error?, ref:DatabaseReference) in
              if let error = error {
                print("Data could not be saved: \(error).")
              } else {
                print("Data saved successfully!")
              }
            }
        }
        */
    }
}

