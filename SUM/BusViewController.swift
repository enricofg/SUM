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
    
    override func viewDidLoad() {
        super.viewDidLoad()

        mapView.delegate = self

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
    

}
