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
    @IBOutlet var beaconIdentifier: UILabel!
    
    var locationManager: CLLocationManager?
    var beaconConstraints = [CLBeaconIdentityConstraint]()
    var beaconRegions = [CLBeaconRegion]()
    
    // Track if we've shown the first detection alert
    var firstDetectionDone = false
    
    // Circle view for animation
    var circleView: UIView!
    
    // Dictionary to store beacon friendly names by UUID
    let beaconNames = [
        "5A4BCFCE-174E-4BAC-A814-092E77F6B7E5": "My Beacon",
        "E2C56DB5-DFFB-48D2-B060-D0F5A71096E0": "Apple AirLocate",
        "74278BDA-B644-4520-8F0C-720EAF059935": "Radius Networks"
    ]

    override func viewDidLoad() {
        super.viewDidLoad()

        locationManager = CLLocationManager()
        locationManager?.delegate = self
        locationManager?.requestAlwaysAuthorization()

        view.backgroundColor = .gray
        
        // Setup the beacon identifier label
        if beaconIdentifier == nil {
            beaconIdentifier = UILabel()
            beaconIdentifier.translatesAutoresizingMaskIntoConstraints = false
            beaconIdentifier.textAlignment = .center
            beaconIdentifier.text = "NO BEACON"
            beaconIdentifier.textColor = .white
            beaconIdentifier.font = UIFont.systemFont(ofSize: 20)
            view.addSubview(beaconIdentifier)
            
            NSLayoutConstraint.activate([
                beaconIdentifier.centerXAnchor.constraint(equalTo: view.centerXAnchor),
                beaconIdentifier.topAnchor.constraint(equalTo: distanceReading.bottomAnchor, constant: 20)
            ])
        }
        
        // Create and configure the circle view
        setupCircleView()
    }
    
    func setupCircleView() {
        circleView = UIView()
        circleView.backgroundColor = .white
        circleView.alpha = 0.4
        circleView.translatesAutoresizingMaskIntoConstraints = false
        
        // Make it circular
        circleView.layer.cornerRadius = 100
        
        view.addSubview(circleView)
        view.sendSubviewToBack(circleView)
        
        NSLayoutConstraint.activate([
            circleView.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            circleView.centerYAnchor.constraint(equalTo: view.centerYAnchor),
            circleView.widthAnchor.constraint(equalToConstant: 200),
            circleView.heightAnchor.constraint(equalToConstant: 200)
        ])
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
        // Add multiple beacon UUIDs
        let uuidStrings = [
            "5A4BCFCE-174E-4BAC-A814-092E77F6B7E5",
            "E2C56DB5-DFFB-48D2-B060-D0F5A71096E0",
            "74278BDA-B644-4520-8F0C-720EAF059935"
        ]
        
        for uuidString in uuidStrings {
            if let uuid = UUID(uuidString: uuidString) {
                let constraint = CLBeaconIdentityConstraint(uuid: uuid)
                beaconConstraints.append(constraint)
                
                let region = CLBeaconRegion(beaconIdentityConstraint: constraint, identifier: uuidString)
                beaconRegions.append(region)
                
                locationManager?.startMonitoring(for: region)
                locationManager?.startRangingBeacons(satisfying: constraint)
            }
        }
    }

    func stopScanning() {
        for constraint in beaconConstraints {
            locationManager?.stopRangingBeacons(satisfying: constraint)
        }
        
        for region in beaconRegions {
            locationManager?.stopMonitoring(for: region)
        }
    }
    
    func locationManager(_ manager: CLLocationManager, didEnterRegion region: CLRegion) {
        if let beaconRegion = region as? CLBeaconRegion {
            let beaconName = beaconNames[beaconRegion.identifier] ?? "Unknown Beacon"
            
            // Show alert only for the first beacon detection
            if !firstDetectionDone {
                firstDetectionDone = true
                
                let ac = UIAlertController(
                    title: "Beacon Detected!",
                    message: "You have come close to the \(beaconName).",
                    preferredStyle: .alert
                )
                
                ac.addAction(UIAlertAction(title: "OK", style: .default))
                present(ac, animated: true)
            }
        }
    }

    func locationManager(_ manager: CLLocationManager, didRange beacons: [CLBeacon], satisfying constraint: CLBeaconIdentityConstraint) {
        if let beacon = beacons.first {
            // Update the second label with the beacon name
            if let beaconName = beaconNames[constraint.uuid.uuidString] {
                self.beaconIdentifier.text = beaconName
            } else {
                self.beaconIdentifier.text = "Unknown Beacon"
            }
            
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
                self.animateCircle(scale: 0.5)
                
            case .near:
                self.view.backgroundColor = .orange
                self.distanceReading.text = "NEAR"
                self.animateCircle(scale: 0.8)
                
            case .immediate:
                self.view.backgroundColor = .red
                self.distanceReading.text = "RIGHT HERE"
                self.animateCircle(scale: 1.2)
                
            default:
                self.view.backgroundColor = .gray
                self.distanceReading.text = "UNKNOWN"
                self.animateCircle(scale: 0.25)
                self.beaconIdentifier.text = "NO BEACON"
            }
        }
    }
    
    func animateCircle(scale: CGFloat) {
        UIView.animate(withDuration: 0.8, delay: 0, usingSpringWithDamping: 0.5, initialSpringVelocity: 0.5, options: [], animations: {
            self.circleView.transform = CGAffineTransform(scaleX: scale, y: scale)
        })
    }
}
