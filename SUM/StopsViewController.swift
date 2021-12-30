//
//  BusViewController.swift
//  SUM
//
//  Created by Luis Sousa on 28/12/2021.
//

import UIKit
import CoreLocation


class StopsViewController: UIViewController,UITableViewDelegate,UITableViewDataSource,CLLocationManagerDelegate, UIPickerViewDelegate, UIPickerViewDataSource
{
    
    @IBOutlet var table: UITableView!
    let data = ["first","second"]
    @IBOutlet weak var Origin: UITextField!
    @IBOutlet weak var button: UIButton!
    @IBOutlet weak var OrigemTF: UITextField!
    @IBOutlet weak var AutocarroTF: UITextField!
    @IBOutlet weak var spinner: UIActivityIndicatorView!
    @IBOutlet weak var _Origin: UIPickerView!
    private var _stops: [Stops]?
    private var _stopsSchedules: [StopSchedules]?
    var selectedRating : Int = 0
    let networkManager = NetworkManager()
 
    //My location
    var locationManager: CLLocationManager?
   
    private let latLngLabel: UILabel = {
          let label = UILabel()
          label.backgroundColor = .systemFill
          label.numberOfLines = 0
          label.textAlignment = .center
          label.font = .systemFont(ofSize: 26)
          return label
      }()
      
    override func viewDidLoad() {
        super.viewDidLoad()
        networkManager.fetchStops { [weak self] (stops) in
            self?._stops = stops
            DispatchQueue.main.async {
                self?._Origin.reloadComponent(0)

            }
        }
        table.dataSource = self
        table.isHidden = true
        table.register(TableViewCell.nib(), forCellReuseIdentifier: TableViewCell.identifier)
        table.delegate = self
        
        _Origin.delegate = self
        _Origin.dataSource = self
        locationManager = CLLocationManager()
        locationManager?.delegate = self
        locationManager?.requestAlwaysAuthorization()
        
        
        //let locationImage=UIImage(systemName: "location.fill")
        //addLeftImageTo(txtField: Origin, andImage: locationImage!)
        
        locationManager?.requestWhenInUseAuthorization()
        getUserLocation()
        
/*        var currentLoc: CLLocation!
        currentLoc = locationManager?.location
     
        
        // my location
        let deviceLocation = CLLocation(latitude: 59.244696, longitude: 17.813868)
        
        //My buddy's location
        let myBuddysLocation = CLLocation(latitude: 59.326354, longitude: 18.072310)

        //Measuring my distance to my buddy's (in km)
        let distance = deviceLocation.distance(from: myBuddysLocation) / 1000
    */
        
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
    @IBAction func SearchTime(_ sender: Any) {
        let currentLoc = locationManager?.location
       // let distance = getDistance(myPositionLatitude: (currentLoc?.coordinate.latitude)!, myPositionLongitude: (currentLoc?.coordinate.longitude)!, pointPositionLatitude: 59.326354, pointPositionLongitude: 18.072310)
       
        // Filter exercises by name (case and diacritic insensitive)
        //let filteredExercises = _stops?.filter {
       //     $0.Stop == selectedRating
        //}
        
 
        networkManager.fetchStopsSchedule(compID: selectedRating){[weak self] (stopsschedules) in
            self?._stopsSchedules = stopsschedules
            DispatchQueue.main.async {
                self?.table.reloadData()

            }
        }

        /*let currentLoc = locationManager?.location
        let deviceLocation = CLLocation(latitude: (currentLoc?.coordinate.latitude)! , longitude: (currentLoc?.coordinate.longitude)!)
        
        let myBuddysLocation = CLLocation(latitude: 59.326354, longitude: 18.072310)

        //Measuring my distance to my buddy's (in km)
        let distance = deviceLocation.distance(from: myBuddysLocation) / 1000
        */
        table.isHidden = false
        
    }

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if (_stops == nil)
        {
            return 0
        }
        return _stopsSchedules!.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier:TableViewCell.identifier, for: indexPath) as! TableViewCell
        let busToShow = _stopsSchedules?[indexPath.row]
        let currentLoc = locationManager?.location
    //    let distance = getDistance(myPositionLatitude: (currentLoc?.coordinate.latitude)!, myPositionLongitude: (currentLoc?.coordinate.longitude)!, //pointPositionLatitude: busToShow!.Latitude, pointPositionLongitude: busToShow!.Longitude)
        cell.textLabel?.text = busToShow!.Schedule_Time //+ String(distance)
        
        cell.detailTextLabel?.text = String(busToShow!.Stop_Id )
          return cell
        
    }
    
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
        return _stops![row].Stop_Name
    }
   
    func pickerView(_ pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
        if (_stops != nil)
        {
            selectedRating = _stops![row].Stop_Id
        }
           
      
        }
    
    
    func addLeftImageTo(txtField: UITextField, andImage img:UIImage){
        let leftImageView = UIImageView(frame:CGRect(x:0.0,y:0.0,width:img.size.width,height:img.size.height))
        leftImageView.image = img;
        txtField.leftView = leftImageView;
        txtField.leftViewMode = .always;
    }
}
