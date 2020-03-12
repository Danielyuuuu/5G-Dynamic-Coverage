//
//  ViewController.swift
//  g5dc
//
//  Created by Owen Liu on 3/11/20.
//  Copyright © 2020 cal. All rights reserved.
//

import UIKit

import CoreMotion
import CoreLocation

class ViewController: UIViewController, CLLocationManagerDelegate{
    
    let motionManager = CMMotionManager()
    var timer: Timer!
    
    override func viewDidLoad() {
        
        // get motion data
        super.viewDidLoad()
        
        motionManager.startAccelerometerUpdates()
        motionManager.startGyroUpdates()
        motionManager.startMagnetometerUpdates()
        motionManager.startDeviceMotionUpdates()
        
        timer = Timer.scheduledTimer(timeInterval: 3.0, target: self, selector: #selector(update), userInfo: nil, repeats: true)
        
        // get connection type
        super.viewDidLoad()
        Monitor().startMonitoring { [weak self] connection, reachable in
            guard let strongSelf = self else { return }
            strongSelf.doSomething(connection, reachable: reachable)
        }
    }
    
    
    // get motion data
    @objc func update() {
        if let accelerometerData = motionManager.accelerometerData {
            print(accelerometerData)
        }
        if let gyroData = motionManager.gyroData {
            print(gyroData)
        }
        if let magnetometerData = motionManager.magnetometerData {
            print(magnetometerData)
        }
        if let deviceMotion = motionManager.deviceMotion {
            print(deviceMotion)
        }
    }
    
    // get connection type
    private func doSomething(_ connection: Connection, reachable: Reachable) {
        print("Current Connection : \(connection) Is reachable: \(reachable)")
    }
    
    @IBOutlet weak var lonView: UITextField!
    @IBOutlet weak var latView: UITextField!
    var locationManager = CLLocationManager()

    override func viewDidAppear(_ animated: Bool) {
        self.locationManager.requestAlwaysAuthorization()
        self.locationManager.requestWhenInUseAuthorization()
        
        if CLLocationManager.locationServicesEnabled(){
            locationManager.delegate = self
            locationManager.desiredAccuracy = kCLLocationAccuracyNearestTenMeters
            locationManager.startUpdatingLocation()
        }
    }
    
    //get location data
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        guard  let trueData: CLLocationCoordinate2D = manager.location?.coordinate else {return}
        print("location = \(trueData.latitude) , \(trueData.longitude)")
        
        //self.latView.text = "Latitude: \(trueData.latitude)"
        //self.lonView.text = "Longitude: \(trueData.longitude)"
    }
    
    
}

