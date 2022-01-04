//
//  BusViewController.swift
//  SUM
//
//  Created by Jose Machado on 24/12/2021.
//

import UIKit
import MapKit

class BusViewController: UIViewController, MKMapViewDelegate {


    @IBOutlet weak var OrigemTF: UITextField!
    @IBOutlet weak var AutocarroTF: UITextField!
    @IBOutlet weak var lotacaoLB: UILabel!
    @IBOutlet weak var DataLB: UILabel!
    @IBOutlet weak var mapView: MKMapView!
    
    let networkManager = NetworkManager()
    let customPin = MKPointAnnotation()
    private var _stops: [Stops]?
    var locationManager: CLLocationManager?
    var selectedRating : Int = 0
    var pickerView = UIPickerView()
    
    override func viewDidLoad() {
        super.viewDidLoad()

        mapView.delegate = self
        
        networkManager.fetchStops { [weak self] (stops) in
            self?._stops = stops
            DispatchQueue.main.async {
                self?.pickerView.reloadComponent(0)

            }
        }
        
        getUserLocation()
    

        let coordinate = CLLocationCoordinate2D(latitude: 39.73594501415817, longitude: -8.817790583959448)
        let span = MKCoordinateSpan(latitudeDelta: 0.01, longitudeDelta: 0.01)
        let region = MKCoordinateRegion(center: coordinate, span: span)
        mapView.setRegion(region, animated: true)
        
        networkManager.fetchBus { [weak self] (bus) in
            DispatchQueue.main.async {
              
                self?.AutocarroTF.text = bus.first?.Bus_Name
            }
        }
        
        DataLB.text = getDate()
        
        pickerView.delegate = self
        pickerView.dataSource = self
        OrigemTF.inputView = pickerView
        
        let locationImage=UIImage(systemName: "location.fill")
        addLeftImageTo(txtField: OrigemTF, andImage: locationImage!)
        
    }
    
    func getDate() -> String {
           let date = Date()
           let calendar = Calendar.current
           
           let day = calendar.component(.day, from: date)
           let month = calendar.component(.month, from: date)
           let year = calendar.component(.year, from: date)
           let hour = calendar.component(.hour, from: date)
           let minute = calendar.component(.minute, from: date)
           
           return "\(day)/\(month)/\(year) \(hour):\(minute)"
       }
    
    func getUserLocation() {
         locationManager = CLLocationManager()
         locationManager?.requestAlwaysAuthorization()
         locationManager?.startUpdatingLocation()
     }
   
   func getDistance(myPositionLatitude: CLLocationDegrees , myPositionLongitude: CLLocationDegrees , pointPositionLatitude:CLLocationDegrees?, pointPositionLongitude:CLLocationDegrees?)->Double
   {
       let deviceLocation = CLLocation(latitude: myPositionLatitude , longitude: myPositionLongitude)
       let pointLocation = CLLocation(latitude: pointPositionLatitude ?? myPositionLatitude, longitude: pointPositionLongitude ?? myPositionLongitude)

       let distance = deviceLocation.distance(from: pointLocation) / 1000
       return distance
       
   }
    
    func addLeftImageTo(txtField: UITextField, andImage img:UIImage){
        let leftImageView = UIImageView(frame:CGRect(x:0.0,y:0.0,width:img.size.width,height:img.size.height))
        leftImageView.image = img;
        txtField.rightView = leftImageView;
        txtField.rightViewMode = .always;
    }
    

}


extension BusViewController : UIPickerViewDelegate, UIPickerViewDataSource{
    
    func numberOfComponents(in pickerView: UIPickerView) -> Int {
        return 1
    }
    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        if (_stops == nil)
        {
            return 1
        }
        return _stops!.count
    }
    func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
       
        if (_stops == nil)
        {
            return nil
        }
        let currentLoc = locationManager?.location

        return "\(_stops![row].Stop_Name) \(getDistance(myPositionLatitude:(currentLoc?.coordinate.latitude)!, myPositionLongitude: (currentLoc?.coordinate.longitude)!, pointPositionLatitude: 59.326354, pointPositionLongitude: 18.072310))"
    }
   
    func pickerView(_ pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
        if (_stops != nil)
        {
            selectedRating = _stops![row].Stop_Id
            OrigemTF.text = "\(_stops![row].Stop_Name)"

            OrigemTF.resignFirstResponder()
        }
    }

}
