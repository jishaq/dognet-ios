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
    @IBOutlet weak var startRecordingButton: UIButton!
    @IBOutlet weak var stopRecordingButton: UIButton!
    
    var locationManager: CLLocationManager!
    var currentlyRecording = false  // Eventually we'll probably read this from a pref
    var dogPark = DogPark(filename: "BristleconeBeach")
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Update status of the start & stop recording buttons:
        refreshRecordButtons()
        
        locationManager = CLLocationManager()
        
        locationManager.delegate = self
        locationManager.desiredAccuracy = kCLLocationAccuracyBest
        locationManager.distanceFilter = kCLHeadingFilterNone   // For now, get all changes in location
        
        
        // If the user hasn't previously granted authorization, this call will immediatly
        // put up a non-blocking dialog requesting authorization.  This dialog will utilize
        // the string at NSLocationWhenInUseUsageDescription.  Once the dialog is dismissed,
        // the user's selection ("Allow" or "Don't Allow") will get passed to the delegate
        // method locationManager(manager, didChangeAuthorizationStatus).
        locationManager.requestWhenInUseAuthorization()
        
        // Fire up location manager now:
        //locationManager.startUpdatingLocation()
        
        // Center the map on the bounding box for the park:
        let latDelta = dogPark.overlayTopLeftCoordinate.latitude - dogPark.overlayBottomRightCoordinate.latitude
        let span = MKCoordinateSpanMake(fabs(latDelta), 0.0)
        let region = MKCoordinateRegionMake(dogPark.midCoordinate, span)
        map.mapType = MKMapType.Satellite
        map.region = region
    }
    
    
    func locationManager(manager: CLLocationManager, didChangeAuthorizationStatus status: CLAuthorizationStatus) {
        // If user authorizes location, let's update the mapview to show user location:
        map.showsUserLocation = (status == .AuthorizedWhenInUse)
        
        // Dump log statement; uses my custom CLAuthorizationStatus protocol extension
        print("Location Manager authorization status changed to \(status)")
    }
    
    func locationManager(manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {

        // Center the map on user's current location and zoom to a ~2000-meter square:
        if (!locations.isEmpty) {
            let centerCoordinate = locations.first!.coordinate
            let region = MapKit.MKCoordinateRegionMakeWithDistance(centerCoordinate, 2000, 2000)
            map.setRegion(region, animated: true)
        }
        
        print(locations[0])
    }
    
    func locationManager(manager: CLLocationManager, didFailWithError error: NSError) {
        // Log:
        print("Location Manager failed with error \(error)")
    }
    

    func addParkBoundary() {
        var boundary = [CLLocationCoordinate2D]()
        let boundaryPointsCount: NSInteger = 4

        // Rough corners of Bristlecone:
        boundary.append(CLLocationCoordinate2D(latitude:  39.182154,  longitude: -120.115496)) // Top Right
        boundary.append(CLLocationCoordinate2D(latitude:  39.181869,  longitude: -120.117059)) // Top Left
        boundary.append(CLLocationCoordinate2D(latitude:  39.180908,  longitude: -120.116832)) // Bottom Left
        boundary.append(CLLocationCoordinate2D(latitude:  39.178951,  longitude: -120.115673)) // Bottom Right

        let polygon = MKPolygon(coordinates: &boundary, count: boundaryPointsCount)
        map.addOverlay(polygon)
    }

    func mapView(mapView: MKMapView!, rendererForOverlay overlay: MKOverlay!) -> MKOverlayRenderer! {
        if overlay is MKPolygon {
            print("Producing a polygon renderer...")
            let polygonView = MKPolygonRenderer(overlay: overlay)
            polygonView.strokeColor = UIColor.magentaColor()
            return polygonView
        }
        else {
            return nil
        }
    }
    
    /*
     * Update enablement state of start/stop recording buttons
     */
    func refreshRecordButtons() {
        startRecordingButton.enabled = currentlyRecording ? false : true
        stopRecordingButton.enabled  = currentlyRecording ? true : false
    }

    @IBAction func recordingButtonToggled(sender: UIButton) {
        // TODO: This is very brittle - if the name of the button changes this will break
        if (sender.currentTitle!.containsString("Stop")) {
            print("Stop recording button tapped")
            currentlyRecording = false
        }
        else {
            print("Start recording button tapped")
            currentlyRecording = true
            
            // Test: Hijack button toggle to add a boundary and see what happens:
            addParkBoundary()
        }
        
        refreshRecordButtons()        
    }
}

