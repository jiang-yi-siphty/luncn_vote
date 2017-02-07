//
//  MainViewController.swift
//  LunchVote
//
//  Created by Yi JIANG on 5/2/17.
//  Copyright © 2017 RobertYiJiang. All rights reserved.
//

import UIKit
import FBSDKCoreKit
import FBSDKShareKit
import FBSDKLoginKit
import CoreLocation
import CoreBluetooth
import MapKit
import MultipeerConnectivity

class MainViewController: UIViewController {
    var localBeacon: CLBeaconRegion!
    var beaconPeripheralData: NSDictionary!
    var peripheralManager: CBPeripheralManager!
    let locationManager = CLLocationManager()
    var matchingItems: [MKMapItem] = [MKMapItem]()
    var advertiser: MCNearbyServiceAdvertiser?

    fileprivate var previousLocationCoordinate: CLLocationCoordinate2D?
    
    @IBOutlet weak var proposalLunchButton: UIButton!
    @IBOutlet weak var restaurantMap: MKMapView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        if (CLLocationManager.authorizationStatus() != .authorizedAlways) {
            locationManager.requestAlwaysAuthorization()
        } else {
            locationManager.delegate = self
            locationManager.startUpdatingLocation()
            restaurantMap.showsUserLocation = true
            restaurantMap.mapType = .standard
            restaurantMap.delegate = self
            var span = MKCoordinateSpan()
            span.latitudeDelta = 0.032
            span.longitudeDelta = 0.032
            var region = MKCoordinateRegion()
            region.center = (locationManager.location?.coordinate)!
            region.span = span
            restaurantMap.setRegion(region, animated: true)
            searchRestaurant()
            let localPeerID = MCPeerID(displayName: LVCacheManager.sharedInstance.multipeerConnect.LocalPeerId!)
            let browser = MCNearbyServiceBrowser(peer: localPeerID,
                                                 serviceType: "LunchVote")
            browser.startBrowsingForPeers()
            browser.delegate = self
        }
    }
    
    override func viewDidAppear(_ animated: Bool) {
        if FBSDKAccessToken.current() == nil {
            routeToUserView()
        }
        if (CLLocationManager.authorizationStatus() != .authorizedWhenInUse) {
            locationManager.requestAlwaysAuthorization()
        } else {
            locationManager.delegate = self
            locationManager.startUpdatingLocation()
            restaurantMap.showsUserLocation = true
            restaurantMap.mapType = .standard
            restaurantMap.delegate = self
            var span = MKCoordinateSpan()
            span.latitudeDelta = 0.032
            span.longitudeDelta = 0.032
            var region = MKCoordinateRegion()
            region.center = (locationManager.location?.coordinate)!
            region.span = span
            restaurantMap.setRegion(region, animated: true)
            searchRestaurant()
            let localPeerID = MCPeerID(displayName: LVCacheManager.sharedInstance.multipeerConnect.LocalPeerId!)
            let browser = MCNearbyServiceBrowser(peer: localPeerID,
                                                 serviceType: "LunchVote")
            browser.startBrowsingForPeers()
            browser.delegate = self
        }
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func routeToUserView(){
        let storyBoard : UIStoryboard = UIStoryboard(name: "Main", bundle:nil)
        let userProfileViewController = storyBoard.instantiateViewController(withIdentifier: "UserProfileView") as! UserProfileViewController
        self.navigationController?.pushViewController(userProfileViewController, animated: true)
    }
  
    @IBAction func proposalLunchButtonTouchUpInside(_ sender: Any) {
        initLocalBeacon()
        
    }

    func initLocalBeacon() {
        if localBeacon != nil {
            stopLocalBeacon()
        }
        
        let localBeaconUUID = LVConstant.Beacon.uuid
        let localBeaconMajor = LVConstant.Beacon.majorValue
        let localBeaconMinor = LVConstant.Beacon.minorValue
        let localBeaconName = LVConstant.Beacon.name
        
        localBeacon = CLBeaconRegion(proximityUUID: localBeaconUUID, major: localBeaconMajor, minor: localBeaconMinor, identifier: localBeaconName)
        
        beaconPeripheralData = localBeacon.peripheralData(withMeasuredPower: nil)
        peripheralManager = CBPeripheralManager(delegate: self, queue: nil, options: nil)
    }
    
    func stopLocalBeacon() {
        peripheralManager.stopAdvertising()
        peripheralManager = nil
        beaconPeripheralData = nil
        localBeacon = nil
    }
    
    func stopMonitoringBeacon() {
        locationManager.stopMonitoring(for: iBeacon.beaconRegion() )
    }
    
    func searchRestaurant() {
        restaurantMap.removeAnnotations(restaurantMap.annotations)
        searchBy("Restaurant", region: restaurantMap.region) { (response, error) in
            if error != nil {
                print("Error occured in search: \(error!.localizedDescription)")
            } else if response!.mapItems.count == 0 {
                print("No matches found")
            } else {
                print("Matches found")
                
                for item in response!.mapItems {
                    print("Name = \(item.name)")
                    self.matchingItems.append(item as MKMapItem)
                    print("Matching items = \(self.matchingItems.count)")
                    
                    let annotation = MKPointAnnotation()
                    annotation.coordinate = item.placemark.coordinate
                    annotation.title = item.name
                    self.restaurantMap.addAnnotation(annotation)
                }
            }
        }
    }
    
    func searchBy(_ naturalLanguageQuery: String, region: MKCoordinateRegion, completionHandler: @escaping (_ response: MKLocalSearchResponse?, _ error: NSError?) -> Void) {
        
        let request = MKLocalSearchRequest()
        request.naturalLanguageQuery = naturalLanguageQuery
        request.region = region
        
        let search = MKLocalSearch(request: request)
        search.start { response, error in
            guard let response = response else {
                completionHandler(nil, error as NSError?)
                
                return
            }
            
            completionHandler(response, error as NSError?)
        }
    }
}

extension MainViewController: CBPeripheralManagerDelegate{
    
    func peripheralManagerDidUpdateState(_ peripheral: CBPeripheralManager) {
        if peripheral.state == .poweredOn {
            peripheralManager.startAdvertising(beaconPeripheralData as! [String: AnyObject]!)
        } else if peripheral.state == .poweredOff {
            peripheralManager.stopAdvertising()
        }
    }
    
}
extension MainViewController: MCNearbyServiceBrowserDelegate {
    // Found a nearby advertising peer.
    func browser(_ browser: MCNearbyServiceBrowser, foundPeer peerID: MCPeerID, withDiscoveryInfo info: [String : String]?) {
        print("Peer ID: \(peerID)")
        print("DiscoveryInfo: \(info)")
    }
    
    
    // A nearby peer has stopped advertising.
    func browser(_ browser: MCNearbyServiceBrowser, lostPeer peerID: MCPeerID) {
        
    }
    
    
    // Browsing did not start due to an error.
    func browser(_ browser: MCNearbyServiceBrowser, didNotStartBrowsingForPeers error: Error) {
        
    }
}
extension MainViewController: MCNearbyServiceAdvertiserDelegate {
    func advertiser(_ advertiser: MCNearbyServiceAdvertiser,
                    didReceiveInvitationFromPeer peerID: MCPeerID,
                    withContext context: Data?,
                    invitationHandler: @escaping (Bool, MCSession?) -> Void)
    {
        let session = MCSession(peer: MCPeerID.init(displayName: LVCacheManager.sharedInstance.multipeerConnect.LocalPeerId!),
                                securityIdentity: nil,
                                encryptionPreference: .none)
        session.delegate = self
        invitationHandler(true, session)
    }
}


extension MainViewController: MCSessionDelegate {
    
    func session(_ session: MCSession, peer peerID: MCPeerID, didChange state: MCSessionState) {
        
    }
    
    
    // Received data from remote peer.
    func session(_ session: MCSession, didReceive data: Data, fromPeer peerID: MCPeerID) {
        
    }
    
    
    // Received a byte stream from remote peer.
    func session(_ session: MCSession, didReceive stream: InputStream, withName streamName: String, fromPeer peerID: MCPeerID) {
        
    }
    
    
    // Start receiving a resource from remote peer.
    func session(_ session: MCSession, didStartReceivingResourceWithName resourceName: String, fromPeer peerID: MCPeerID, with progress: Progress) {
        
    }
    
    
    // Finished receiving a resource from remote peer and saved the content
    // in a temporary location - the app is responsible for moving the file
    // to a permanent location within its sandbox.
    func session(_ session: MCSession, didFinishReceivingResourceWithName resourceName: String, fromPeer peerID: MCPeerID, at localURL: URL, withError error: Error?) {
        
    }
    
}

extension MainViewController: MKMapViewDelegate {
    func mapView(_ mapView: MKMapView, regionWillChangeAnimated animated: Bool) {
        
        
    }
    
    func mapView(_ mapView: MKMapView, regionDidChangeAnimated animated: Bool) {
        searchRestaurant()
    }
    
    func mapView(_ mapView: MKMapView, didSelect view: MKAnnotationView) {
        // Do any additional setup after loading the view, typically from a nib.
        let localPeerID = MCPeerID(displayName: LVCacheManager.sharedInstance.multipeerConnect.LocalPeerId!)
        var restaurantDetileDic = [String: String]()
        advertiser?.stopAdvertisingPeer()
        restaurantDetileDic["RestAurantName"] = (view.annotation?.title)!
        advertiser = MCNearbyServiceAdvertiser(peer: localPeerID,
                                               discoveryInfo: restaurantDetileDic,
                                               serviceType: "LunchVote")
        advertiser?.delegate = self
        advertiser?.startAdvertisingPeer()
    }
    
    
    func mapView(_ mapView: MKMapView, didDeselect view: MKAnnotationView) {
        
        advertiser?.stopAdvertisingPeer()
    }
    

    
}

extension MainViewController: CLLocationManagerDelegate {
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        
        if previousLocationCoordinate == nil {
            previousLocationCoordinate = locations.last?.coordinate
        } else {
            let savedLocation = CLLocation(latitude: previousLocationCoordinate!.latitude, longitude: previousLocationCoordinate!.longitude)
            let movementDistance = locations.last!.distance(from: savedLocation)
            if movementDistance > 50 { // if user movemnet was greater than the threshold then update the stores
                previousLocationCoordinate = locations.last?.coordinate
                let location = locations.last
                var span = MKCoordinateSpan()
                span.latitudeDelta = 0.032
                span.longitudeDelta = 0.032
                var region = MKCoordinateRegion()
                region.center = (locations.last?.coordinate)!
                region.span = span
                region.center = (location?.coordinate)!
                restaurantMap.setRegion(region, animated: true)
            }
        }
        
    }
    
    func locationManager(_ manager: CLLocationManager, didChangeAuthorization status: CLAuthorizationStatus) {
        if status == .authorizedAlways {
            locationManager.delegate = self
            locationManager.startUpdatingLocation()
            restaurantMap.showsUserLocation = true
            restaurantMap.mapType = .standard
            restaurantMap.delegate = self
            var span = MKCoordinateSpan()
            span.latitudeDelta = 0.032
            span.longitudeDelta = 0.032
            var region = MKCoordinateRegion()
            region.center = (locationManager.location?.coordinate)!
            region.span = span
            restaurantMap.setRegion(region, animated: true)
            searchRestaurant()
            let localPeerID = MCPeerID(displayName: LVCacheManager.sharedInstance.multipeerConnect.LocalPeerId!)
            let browser = MCNearbyServiceBrowser(peer: localPeerID,
                                                 serviceType: "LunchVote")
            browser.startBrowsingForPeers()
            browser.delegate = self
        }
    }
}

