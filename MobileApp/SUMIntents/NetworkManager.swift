//
//  NetworkManager.swift
//  SUMIntents
//
//  Created by Enrico Florentino Gomes on 16/01/2022.
//

import Foundation

class NetworkManager {
    
    let domainUrl = "https://smarturbanmoving.azurewebsites.net/"
    
    func fetchBus(busNumber: Int? = nil, completionHandler: @escaping ([Bus]) -> Void) {
        var url = URL(string: domainUrl + "api/buses")!
        
        if busNumber ?? -1 >= 0 {
            url = URL(string: domainUrl + "api/buses/\(busNumber ?? 0)")!
            print(url)
        }
        
        let task = URLSession.shared.dataTask(with: url, completionHandler: { (data, response, error) in
            if let error = error {
                print("Error with fetching buses: \(error)")
                return
            }
            
            if let data = data {
                do {
                    let toDos = try JSONDecoder().decode([Bus].self, from: data)
                    completionHandler(toDos)
                } catch let decoderError {
                    print(decoderError)
                }
            }
        })
        task.resume()
    }
    
    func fetchStops(completionHandler: @escaping ([Stops]) -> Void) {
        let url = URL(string: domainUrl + "api/stops")!
        
        
        let task = URLSession.shared.dataTask(with: url, completionHandler: { (data, response, error) in
            if let error = error {
                print("Error with fetching stops: \(error)")
                return
            }
            
            if let data = data {
                do {
                    let toDos = try JSONDecoder().decode([Stops].self, from: data)
                    completionHandler(toDos)
                } catch let decoderError {
                    print(decoderError)
                }
            }
        })
        task.resume()
    }
    
    func fetchStopsSchedule(compID : Int,  completionHandler: @escaping ([StopSchedules]) -> Void) {
        
        let url = URL(string: domainUrl + "api/stopsschedules/"+String(compID))!
        
        let task = URLSession.shared.dataTask(with: url, completionHandler: { (data, response, error) in
            if let error = error {
                print("Error with fetching stops: \(error)")
                return
            }
            
            if let data = data {
                do {
                    let toDos = try JSONDecoder().decode([StopSchedules].self, from: data)
                    completionHandler(toDos)
                } catch let decoderError {
                    print(decoderError)
                }
            }
        })
        task.resume()
    }
}
