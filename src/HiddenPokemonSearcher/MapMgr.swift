//
//  MapMgr.swift
//

import UIKit
import CoreLocation

/**
 - [ENG]The UIViewController for location.
 - [JPN]位置管理用 UIViewController
 - Author: xinext HF
 - Copyright: xinext
 - Date: 2016/10/31
 - Version: 1.0.0
 */
class LocationMgr: UIViewController, CLLocationManagerDelegate {

    // MARK: - Internal
    var latitude: CLLocationDegrees? = nil
    var longitude: CLLocationDegrees? = nil
    var available: Bool = false
    
    // MARK: - Private
    private var _locationMgr: CLLocationManager! = nil
    private var _pcv: UIViewController! = nil
    
    // MARK: - UIViewController
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    // MARK: - CLLocationManager
    /**
     [Delegate] requestWhenInUseAuthorization
     */
    func locationManager(_ manager: CLLocationManager, didChangeAuthorization status: CLAuthorizationStatus) {
        switch status {
        case .notDetermined:
            _locationMgr.requestWhenInUseAuthorization()
            break
        case .restricted, .denied:
            SimpleAlert.NaviToSetPageMsg(pcv: _pcv, msg: NSLocalizedString("MSG_LOCATION_REQ_AUTHORIZATION", comment: ""))
            break
        case .authorizedAlways, .authorizedWhenInUse:
            print(".authorizedAlways, .authorizedWhenInUse")
            break
        }
    }
    
    /**
     [Delegate] get locations
     */
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        
        guard let newLocation = locations.last else {
            return
        }
        
        available = true
        latitude = newLocation.coordinate.latitude
        longitude = newLocation.coordinate.longitude
        
        print(latitude ?? "nil")
        print(longitude ?? "nil")
        
#if DEBUG
    latitude = 36.5630188
    longitude = 136.6640123
#endif
    }
    
    /**
     [Delegate] error occurred
     */
    func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
        
        available = false
        latitude = nil
        longitude = nil
        
        print(latitude ?? "nil")
        print(longitude ?? "nil")
    }

    // MARK: - Private method
    /**
     Initialization of processing
     - parameter pvc: ViewController Parent ViewController.
     - parameter map: MKMapView which is used for display.
     - returns: nothing
     */
    func initMgr(pvc: UIViewController) {
        _pcv = pvc
        
        _locationMgr = CLLocationManager()
        _locationMgr.delegate = self
        _locationMgr.requestWhenInUseAuthorization()
        
        _locationMgr.desiredAccuracy = kCLLocationAccuracyBest
    }
    
    // MARK: - Internal method
    func StartLocationSearch() {
        if _locationMgr != nil {
            _locationMgr.startUpdatingLocation()
        }
    }
    
    func StopLocationSearch() {
        if _locationMgr != nil {
            _locationMgr.stopUpdatingLocation()
        }
    }
}
