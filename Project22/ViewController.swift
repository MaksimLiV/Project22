//
//  ViewController.swift
//  Project22
//
//  Created by Maksim Li on 23/04/2025.
//

import UIKit
import CoreLocation

class ViewController: UIViewController, CLLocationManagerDelegate {

    @IBOutlet var distanceReading: UILabel!
    
    var locationManager: CLLocationManager?
    var beaconConstraint: CLBeaconIdentityConstraint?

    override func viewDidLoad() {
        super.viewDidLoad()

        locationManager = CLLocationManager()
        locationManager?.delegate = self
        locationManager?.requestAlwaysAuthorization()

        view.backgroundColor = .gray
    }

    func locationManager(_ manager: CLLocationManager, didChangeAuthorization status: CLAuthorizationStatus) {
        if status == .authorizedAlways {
            if CLLocationManager.isMonitoringAvailable(for: CLBeaconRegion.self),
               CLLocationManager.isRangingAvailable() {
                startScanning()
            }
        }
    }

    func startScanning() {
        if let uuid = UUID(uuidString: "5A4BCFCE-174E-4BAC-A814-092E77F6B7E5") {
            beaconConstraint = CLBeaconIdentityConstraint(uuid: uuid, major: 123, minor: 456)
            
            let beaconRegion = CLBeaconRegion(beaconIdentityConstraint: beaconConstraint!, identifier: "MyBeacon")
            locationManager?.startMonitoring(for: beaconRegion)
            locationManager?.startRangingBeacons(satisfying: beaconConstraint!)
        } else {
            print("Invalid UUID format")
        }
    }

    func stopScanning() {
        if let constraint = beaconConstraint {
            locationManager?.stopRangingBeacons(satisfying: constraint)
            locationManager?.stopMonitoring(for: CLBeaconRegion(beaconIdentityConstraint: constraint, identifier: "MyBeacon"))
        }
    }

    func locationManager(_ manager: CLLocationManager, didRange beacons: [CLBeacon], satisfying constraint: CLBeaconIdentityConstraint) {
        if let beacon = beacons.first {
            update(distance: beacon.proximity)
        } else {
            update(distance: .unknown)
        }
    }

    func update(distance: CLProximity) {
        UIView.animate(withDuration: 1) {
            switch distance {
            case .far:
                self.view.backgroundColor = .blue
                self.distanceReading.text = "FAR"
            case .near:
                self.view.backgroundColor = .orange
                self.distanceReading.text = "NEAR"
            case .immediate:
                self.view.backgroundColor = .red
                self.distanceReading.text = "RIGHT HERE"
            default:
                self.view.backgroundColor = .gray
                self.distanceReading.text = "UNKNOWN"
            }
        }
    }
}
