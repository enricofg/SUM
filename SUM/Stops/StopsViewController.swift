//
//  BusViewController.swift
//  SUM
//
//  Created by Luis Sousa on 28/12/2021.
//

import UIKit
import CoreLocation


class StopsViewController: UIViewController,CLLocationManagerDelegate
{
    
    @IBOutlet var table: UITableView!
    @IBOutlet weak var Origin: UITextField!
    @IBOutlet weak var button: UIButton!
    @IBOutlet weak var OrigemTF: UITextField!
    @IBOutlet weak var AutocarroTF: UITextField!
    @IBOutlet weak var spinner: UIActivityIndicatorView!
    @IBOutlet weak var _Origin: UIPickerView!
    private var _stops: [Stops]?
    private var _stopsSchedules: [StopSchedules]?
    var selectedRating : Int = 0
    @IBOutlet weak var txtOrigin: UITextField!
    @IBOutlet weak var txtHours: UITextField!
    
    let networkManager = NetworkManager()
    let tableView = UITableView()
    var pickerView = UIPickerView()
    let datePicker = UIDatePicker()
    //My location
    var locationManager: CLLocationManager?
    var receivedStop:Int?
   
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
        
        view.addSubview(tableView)
        tableView.delegate=self
        tableView.dataSource=self
        networkManager.fetchStops { [weak self] (stops) in
            self?._stops = stops
            DispatchQueue.main.async { [self] in
                self?.pickerView.reloadComponent(0)

                //set selected stop if a stop was received
                if self!.receivedStop != nil {
                    let child = self!._stops!.first(where: {$0.Stop_Id == self!.receivedStop})
                    self!.selectedRating = child?.Stop_Id ?? 0
                    self!.txtOrigin.text = "\(child?.Stop_Name ?? "")"
                    self!.SearchTime(_ : (Any).self)
                }
            }
        }
        table.dataSource = self
        table.isHidden = true
        table.register(TableViewCell.nib(), forCellReuseIdentifier: TableViewCell.identifier)
        table.delegate = self
        pickerView.delegate = self
        pickerView.dataSource = self
        txtOrigin.inputView = pickerView
        txtHours.inputView = datePicker
        locationManager = CLLocationManager()
        locationManager?.delegate = self
        locationManager?.requestAlwaysAuthorization()
        
        locationManager?.requestWhenInUseAuthorization()
        getUserLocation()
        createDatePicker()
        let locationImage=UIImage(systemName: "location.fill")
        addLeftImageTo(txtField: txtOrigin, andImage: locationImage!)
        let hourImage=UIImage(systemName: "calendar")
        addLeftImageTo(txtField: txtHours, andImage: hourImage!)
        
       
        
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
    func createToolBar() -> UIToolbar {
        let toolbar = UIToolbar()
        toolbar.sizeToFit()
        
        let doneBtn = UIBarButtonItem(barButtonSystemItem: .done, target: nil, action: #selector(donePressed))
        toolbar.setItems([doneBtn], animated: true)
        
        return toolbar
    }
    func createDatePicker(){
        
        datePicker.preferredDatePickerStyle = .wheels
        datePicker.datePickerMode = .dateAndTime
        txtHours.inputAccessoryView = createToolBar()
        txtHours.inputView = datePicker
        
        //set current date if a stop was received
        if receivedStop != nil {
            self.txtHours.text = "\(Date())"
        }
        
    }
    @objc func donePressed(){
        self.txtHours.text = "\(datePicker.date)"
        self.view.endEditing(true)
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
        table.isHidden = false
    }

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if (_stopsSchedules == nil)
        {
            return 0
        }
        return (_stopsSchedules![section].StopSchedule.count)
       
    }

    func numberOfSections(in tableView: UITableView) -> Int {
        if (_stopsSchedules == nil)
        {
            return 0
        }
        return _stopsSchedules!.count
    }

    func addLeftImageTo(txtField: UITextField, andImage img:UIImage){
        let leftImageView = UIImageView(frame:CGRect(x:0.0,y:0.0,width:img.size.width,height:img.size.height))
        leftImageView.image = img;
        txtField.rightView = leftImageView;
        txtField.rightViewMode = .always;
    }
}

extension StopsViewController : UIPickerViewDelegate, UIPickerViewDataSource,UITableViewDelegate,UITableViewDataSource{
    
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
        
        if(currentLoc == nil)
        {
            return  "\(_stops![row].Stop_Name)"
        }
        
        return "\(_stops![row].Stop_Name) \(getDistance(myPositionLatitude:(currentLoc?.coordinate.latitude)!, myPositionLongitude: (currentLoc?.coordinate.longitude)!, pointPositionLatitude: 59.326354, pointPositionLongitude: 18.072310))"
    }
   
    func pickerView(_ pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
        if (_stops != nil)
        {
            selectedRating = _stops![row].Stop_Id
            txtOrigin.text = "\(_stops![row].Stop_Name)"

            
            txtOrigin.resignFirstResponder()
        }
    }
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier:TableViewCell.identifier, for: indexPath) as! TableViewCell
        let busToShow = _stopsSchedules?[indexPath.section].StopSchedule[indexPath.row]
    //    let distance = getDistance(myPositionLatitude: (currentLoc?.coordinate.latitude)!, myPositionLongitude: (currentLoc?.coordinate.longitude)!, //pointPositionLatitude: busToShow!.Latitude, pointPositionLongitude: busToShow!.Longitude)
        cell.textLabel?.text = busToShow!.Schedule_Time //+ String(distance)
        cell.btnShare.tag = indexPath.row
        cell.btnShare.titleLabel!.tag = indexPath.section
        cell.btnShare.addTarget(self, action: #selector(addToButton), for: .touchUpInside)
        cell.detailTextLabel?.text = String(busToShow!.Stop_Id )
          return cell
        
    }
    @objc func addToButton(sender:UIButton)
    {
        let indexpath = IndexPath(row: sender.tag, section: sender.titleLabel!.tag)
        let title = "Autocarro disponível na linha \(_stopsSchedules![indexpath.section].Line_Name) às  \(_stopsSchedules![indexpath.section].StopSchedule[indexpath.row].Schedule_Time) horas"
        let activityViewController = UIActivityViewController(activityItems: [title] , applicationActivities: nil)
       
         activityViewController.popoverPresentationController?.sourceView = self.view
         self.present(activityViewController, animated: true, completion: nil)
        
    }
    func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        return _stopsSchedules![section].Line_Name
        
     }
}
