//
//  SecondViewController.swift
//  Dognet
//
//  Created by Jeff Ishaq on 4/25/16.
//  Copyright © 2016 Snowdog Software. All rights reserved.
//

import UIKit
import MapKit
import CoreLocation

/*
 * CLAuthorizationStatus Protocol Extension
 *
 * Implements CustomStringConverible protocol upon the CLAuthorizationStatus enum, for easy logging
 * of its enum value.  If this enum were declared in swift, this would happen automatically but
 * at present, CLLocationManager is Objective C.  For example, in your locationManager(manager,
 * didChangeAuthorizationStatus) delegate, you can do:
 *
 *   print("Authorization status changed to \(status)")
 *
 * See Also: https://appventure.me/2015/10/17/advanced-practical-enum-examples/#sec-2-2
 * See Also: 
 * JeffI 2016-04-27 Initial implementation
 */
extension CLAuthorizationStatus: CustomStringConvertible {
    public var description: String {
        switch self {
        case .AuthorizedAlways: return "AuthorizedAlways"
        case .AuthorizedWhenInUse: return "AuthorizedWhenInUse"
        case .Denied: return "Denied"
        case .NotDetermined: return "NotDetermined"
        case .Restricted: return "Restricted"
        }
    }
}

class RecordViewController: UIViewController, CLLocationManagerDelegate {

    @IBOutlet weak var map: MKMapView!
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
    }

}

