//
//  NetworkManager.swift
//  SUM
//
//  Created by Jose Machado on 24/12/2021.
//  Updated by Luis Sousa on 29/12/2021.

import Foundation

class NetworkManager {
    
    let domainUrl = "https://smarturbanmoving.azurewebsites.net/"

    
    
    func fetchBus(completionHandler: @escaping ([Bus]) -> Void) {
        let url = URL(string: domainUrl + "api/buses")!
        

        let task = URLSession.shared.dataTask(with: url, completionHandler: { (data, response, error) in
          if let error = error {
            print("Error with fetching buses: \(error)")
            return
          }
            
            /*
          guard let httpResponse = response as? HTTPURLResponse,
                (200...299).contains(httpResponse.statusCode) else {
            print("Error with the response, unexpected status code: \(response)")
            return
          }
             */
             
            
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
