//
//  ViewController.swift
//  dynamic
//
//  Created by shenglanyu on 3/3/20.
//  Copyright © 2020 shenglanyu. All rights reserved.
//

import UIKit
import CoreLocation
import CoreMotion
import Firebase
import MapKit
import CoreTelephony

class ViewController: UIViewController, CLLocationManagerDelegate {
    
    let locman = CLLocationManager()
    let motion = CMMotionManager()
    
    var location: CLLocation?
    var startTime: Date?
    var timer: Timer!
    
    let hz = 1.0
    
    var ref: DatabaseReference!
    let id = UIDevice.current.identifierForVendor!.uuidString
    
    
    @IBOutlet weak var latency: UILabel!
    
    @IBOutlet weak var longitude: UILabel!
    
    @IBOutlet weak var latitude: UILabel!
    
    @IBOutlet weak var xacc: UILabel!
    
    @IBOutlet weak var yacc: UILabel!
    
    @IBOutlet weak var zacc: UILabel!
    
    @IBOutlet weak var xrot: UILabel!
    
    @IBOutlet weak var yrot: UILabel!
    
    @IBOutlet weak var zrot: UILabel!
    
    lazy var functions = Functions.functions()
    
    @IBOutlet weak var connection: UILabel!
    
    @IBOutlet weak var roamButton: UIButton!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        locman.requestAlwaysAuthorization()
        locman.requestWhenInUseAuthorization()
        ref = Database.database().reference()
        
        if self.motion.isAccelerometerAvailable {
            self.motion.accelerometerUpdateInterval = hz
            self.motion.startAccelerometerUpdates()
        }
        
        if motion.isGyroAvailable {
            self.motion.gyroUpdateInterval = hz
            self.motion.startGyroUpdates()
        }
        
        if motion.isMagnetometerAvailable {
            self.motion.magnetometerUpdateInterval = hz
            self.motion.startMagnetometerUpdates()
        }
        
        // currently not in use
        if motion.isDeviceMotionAvailable {
            self.motion.deviceMotionUpdateInterval = hz
            self.motion.startDeviceMotionUpdates()
        }
        
        self.timer = Timer(fire: Date(), interval: (hz),
              repeats: true, block: { (timer) in
                let motionDict = self.updateMotionData()
                let networks = self.getNetworkInfo()
                self.pingFirebase(motionDict: motionDict, networks:networks)
        })
        
    }
    
    func getNetworkInfo() -> [Dictionary<String,String>] {
        let networkInfo = CTTelephonyNetworkInfo()
        let networkSims = networkInfo.serviceCurrentRadioAccessTechnology
        let carrier = networkInfo.serviceSubscriberCellularProviders
        
        var networks: [Dictionary<String,String>] = []
        
        for sim in networkSims!.keys {
            let carrierName = carrier![sim]?.carrierName
            let networkString = networkSims![sim]
            var dict = ["name": carrierName]
            
            if networkString == CTRadioAccessTechnologyLTE{
                dict["type"] = "4G"
                if sim == "0000000100000001" {
                    connection.text = "4G"
                }
            } else if networkString == CTRadioAccessTechnologyWCDMA{
                dict["type"] = "3G"
                if sim == "0000000100000001" {
                    connection.text = "3G"
                }
            } else if networkString == CTRadioAccessTechnologyEdge{
                dict["type"] = "2G"
                if sim == "0000000100000001" {
                    connection.text = "2G"
                }
            } else {
                dict["type"] = "unknow"
                if sim == "0000000100000001" {
                    connection.text = "/"
                }
            }
            
            networks.append(dict as! [String : String])
        }
        
        return networks
    }
    
    func updateMotionData() -> Dictionary<String, Double> {
        var dict: [String: Double] = [:]
        if let data = self.motion.accelerometerData {
            dict["x_accel"] = data.acceleration.x
            dict["y_accel"] = data.acceleration.y
            dict["z_accel"] = data.acceleration.z
            xacc.text = String(format: "%.2f", data.acceleration.x)
            yacc.text = String(format: "%.2f", data.acceleration.y)
            zacc.text = String(format: "%.2f", data.acceleration.z)
        }
        
        if let data = self.motion.gyroData {
           dict["x_rot"] = data.rotationRate.x
           dict["y_rot"] = data.rotationRate.y
           dict["z_rot"] = data.rotationRate.z
           xrot.text = String(format: "%.2f", data.rotationRate.x)
           yrot.text = String(format: "%.2f", data.rotationRate.y)
           zrot.text = String(format: "%.2f", data.rotationRate.z)
        }
        
        if let data = self.motion.magnetometerData {
            dict["x_mag"] = data.magneticField.x
            dict["y_mag"] = data.magneticField.y
            dict["z_mag"] = data.magneticField.z
        }
        
        return dict
    }
    
    func pingFirebase(motionDict:Dictionary<String, Double>, networks:[Dictionary<String,String>]) {
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
              // not handled now
            }
            
          }
            if ((result?.data as? [String: Any])?["result"] as? String) != nil {
            let elpased = timer.stop()
                self.latency.text = String(format: "%.2f", elpased)
            
            if
               CLLocationManager.authorizationStatus() == CLAuthorizationStatus.authorizedWhenInUse ||
               CLLocationManager.authorizationStatus() ==  CLAuthorizationStatus.authorizedAlways
            {
                currentLocation = self.locman.location
                self.longitude.text = String(format: "%.2f", currentLocation.coordinate.longitude)
                self.latitude.text = String(format: "%.2f", currentLocation.coordinate.latitude)
            self.ref.child("usrData").child(dateString).child(self.id).setValue(["longitude": currentLocation.coordinate.longitude, "latitude": currentLocation.coordinate.latitude, "latency": elpased]) {
            
                    (error:Error?, ref:DatabaseReference) in
                    if let error = error {
                        print("Location Data could not be saved: \(error).")
                    } else {
                        print("Location Data saved successfully!")
                    }
                }
            }
            
        self.ref.child("usrData").child(dateString).child(self.id).updateChildValues(motionDict) {
                (error:Error?, ref:DatabaseReference) in
                if let error = error {
                    print("Motion Data could not be saved: \(error).")
                } else {
                    print("Motion Data saved successfully!")
                }
            }
        self.ref.child("usrData").child(dateString).child(self.id).updateChildValues(["cellularInfo":networks, "latency":elpased]) {
                (error:Error?, ref:DatabaseReference) in
                if let error = error {
                    print("Network Data could not be saved: \(error).")
                } else {
                    print("Network Data saved successfully!")
                }
            }
          }
        }
    }
    
    @IBAction func roam(_ sender: Any) {
        if roamButton.currentTitle != "Stop" {
            self.timer = Timer(fire: Date(), interval: (hz),
                  repeats: true, block: { (timer) in
                    let motionDict = self.updateMotionData()
                    let networks = self.getNetworkInfo()
                    self.pingFirebase(motionDict: motionDict, networks:networks)
            })
            RunLoop.current.add(self.timer!, forMode: .common)
            roamButton.setTitle("Stop", for: .normal)
        } else {
            self.timer.invalidate()
            roamButton.setTitle("Roam Now", for: .normal)
        }
    }
    
}

