//
//  RequestViewController.swift
//  hitorwait
//
//  Created by Yongsung on 2/15/17.
//  Copyright © 2017 Delta. All rights reserved.
//

import UIKit
import MapKit

class RequestViewController: UIViewController, MKMapViewDelegate, UITextFieldDelegate{

    @IBOutlet weak var itemTextField: UITextField!
    @IBOutlet weak var itemDetailTextField: UITextField!
    @IBOutlet weak var latTextField: UITextField!
    @IBOutlet weak var lonTextField: UITextField!
    @IBOutlet weak var mapView: MKMapView!
    
    var lostItemCoordinate: CLLocationCoordinate2D?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        itemTextField.delegate = self
        itemDetailTextField.delegate = self
        
        //initializing annonation and map
        dropPins()
        mapViewSetup()
        // Do any additional setup after loading the view.
    }
    
    override func viewWillAppear(_ animated: Bool) {
        let lat = Pretracker.sharedManager.currentLocation?.coordinate.latitude ?? 0.0
        let lon = Pretracker.sharedManager.currentLocation?.coordinate.longitude ?? 0.0
        if lat != 0.0 {
            let params = ["view":"requestView","user":(CURRENT_USER?.username)! ?? "","time":Date().timeIntervalSince1970,"lat":String(describing: lat),"lon":String(describing: lon)] as [String: Any]
            CommManager.instance.urlRequest(route: "appActivity", parameters: params, completion: {
                json in
                print (json)
                // if there is no nearby search region with the item not found yet, server returns {"result":0}
            })
        }

    }
    
    // ways to make keyboard disappear.
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        return true
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        self.view.endEditing(true)
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func mapViewSetup() {
        self.mapView.delegate = self
        self.mapView.showsUserLocation = true
        var center = CLLocationCoordinate2D()
        center.latitude = 42.056929
        center.longitude = -87.676519
        let region = MKCoordinateRegionMakeWithDistance (center, 1000, 1000)
        self.mapView.setRegion(region, animated: false)
        self.mapView.showsBuildings = true
    }
   
    @IBAction func requestButtonClick(_ sender: UIButton) {
        
        if let lat = lostItemCoordinate?.latitude {
            let params = ["user":(CURRENT_USER?.username)!, "item": (itemTextField.text)! ?? "", "detail": (itemDetailTextField.text)! ?? "", "lat":lat, "lon":(lostItemCoordinate?.longitude)! ?? 0.0] as [String : Any]
            
            CommManager.instance.urlRequest(route: "regions", parameters: params){
                json in
                if let result = json["result"] as? String {
                    if result == "not requester" {
                        self.showNotRequesterAlert()
                    } else if result == "success" {
                        self.showSuccessAlert()
                    }
                }
            }
        }

        print("requested")
    }
    
    func showNotRequesterAlert() {
        DispatchQueue.main.async {
            let alert = UIAlertController(title: "Sorry", message: "Only authorized requesters can request.", preferredStyle: UIAlertControllerStyle.alert)
            let okAction = UIAlertAction(title: "Dismiss", style: UIAlertActionStyle.default)
            
            alert.addAction(okAction)
            self.present(alert, animated: true, completion: nil)
            
            self.itemTextField.text = ""
            self.itemDetailTextField.text = ""
            self.mapView.removeAnnotations(self.mapView.annotations)
        }
    }

    func showSuccessAlert() {
        DispatchQueue.main.async {
            let alert = UIAlertController(title: "Thanks!", message: "We will help you find the item soon.", preferredStyle: UIAlertControllerStyle.alert)
            let okAction = UIAlertAction(title: "Dismiss", style: UIAlertActionStyle.default)
            
            alert.addAction(okAction)
            self.present(alert, animated: true, completion: nil)
            
            self.itemTextField.text = ""
            self.itemDetailTextField.text = ""
            self.mapView.removeAnnotations(self.mapView.annotations)
        }
    }
    
     /*
        let config = URLSessionConfiguration.default
        let session: URLSession = URLSession(configuration: config)
        var request = URLRequest(url: URL(string: "\(Config.URL)/regions")!)
        
        request.httpMethod = "POST"
        print(username)
        let json = ["user":username,"item":itemTextField.text ?? "", "detail":itemDetailTextField.text ?? "", "lat": latTextField.text ?? "", "lng": lonTextField.text ?? ""] as [String : Any]
        
        do {
            let jsonData = try JSONSerialization.data(withJSONObject: json, options: .prettyPrinted)
            request.setValue("application/json; charset=utf-8", forHTTPHeaderField: "Content-Type")
            request.httpBody = jsonData
            
            let task = session.dataTask(with: request, completionHandler: {
                (data, response, error) in
                if error != nil {
                    print(error?.localizedDescription)
                }
                print(response)
            })
            task.resume()
            
        } catch let error as NSError {
            //TODO: wherever there is an error, log it to the server.
            print(error)
        }
    }
    */
    
    func dropPins() {
        let longPressGesture = UILongPressGestureRecognizer(target: self, action: #selector(handleLongPress(gesture:)))
        longPressGesture.minimumPressDuration = 0.1
        self.mapView.addGestureRecognizer(longPressGesture)
    }
    
    func handleLongPress(gesture: UIGestureRecognizer) {
        if (gesture.state != UIGestureRecognizerState.began) {
            return
        }
        
        let touchPoint: CGPoint = gesture.location(in: mapView)
        let touchMapCoordinate: CLLocationCoordinate2D = self.mapView.convert(touchPoint, toCoordinateFrom: mapView)
        
        self.lostItemCoordinate = touchMapCoordinate
        
        let point: MKPointAnnotation = MKPointAnnotation()
        point.title = "Lost item location"
        point.coordinate = touchMapCoordinate
        mapView.removeAnnotations(self.mapView.annotations)
        mapView.addAnnotation(point)
    }
    
    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

}
