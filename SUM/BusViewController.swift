//
//  BusViewController.swift
//  SUM
//
//  Created by Jose Machado on 24/12/2021.
//

import UIKit

class BusViewController: UIViewController {


    @IBOutlet weak var OrigemTF: UITextField!
    @IBOutlet weak var AutocarroTF: UITextField!
    @IBOutlet weak var lotacaoLB: UILabel!
    @IBOutlet weak var DataLB: UILabel!
    
    let networkManager = NetworkManager()
    
    override func viewDidLoad() {
        super.viewDidLoad()

        
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
