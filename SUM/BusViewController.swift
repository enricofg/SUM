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
    @IBOutlet weak var spinner: UIActivityIndicatorView!
    
    let networkManager = NetworkManager()
    
    override func viewDidLoad() {
        super.viewDidLoad()

        spinner.isHidden = false
        spinner.startAnimating()
        
        networkManager.fetchBus { [weak self] (bus) in
            DispatchQueue.main.async {
                self?.spinner.isHidden = true
                self?.spinner.stopAnimating()
                
                self?.AutocarroTF.text = bus.first?.Bus_Name
            }
        }
        
    }
    


}
