//
//  NetworkManager.swift
//  SUM
//
//  Created by Jose Machado on 24/12/2021.
//  Updated by Luis Sousa on 29/12/2021.

import Foundation

class NetworkManager {
    
    let domainUrl = "https://smarturbanmoving.azurewebsites.net/"
    
    func fetchBus(busNumber: Int? = nil, completionHandler: @escaping ([Bus]) -> Void) {
        var url = URL(string: domainUrl + "api/buses")!
        
        if busNumber ?? -1>=0 {
            url = URL(string: domainUrl + "api/buses/\(busNumber ?? 0)")!
            print(url)
        }
        
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
    
    func fetchStopsList(completionHandler: @escaping ([StopsList]) -> Void) {
        let url = URL(string: domainUrl + "api/stopsList")!
        
        
        let task = URLSession.shared.dataTask(with: url, completionHandler: { (data, response, error) in
            if let error = error {
                print("Error with fetching StopsList: \(error)")
                return
            }
            
            if let data = data {
                do {
                    let toDos = try JSONDecoder().decode([StopsList].self, from: data)
                    completionHandler(toDos)
                } catch let decoderError {
                    print(decoderError)
                }
            }
        })
        task.resume()
    }
    
    func fetchLines(completionHandler: @escaping ([Lines]) -> Void) {
        let url = URL(string: domainUrl + "api/lines")!
        
        
        let task = URLSession.shared.dataTask(with: url, completionHandler: { (data, response, error) in
            if let error = error {
                print("Error with fetching stops: \(error)")
                return
            }
            
            if let data = data {
                do {
                    let toDos = try JSONDecoder().decode([Lines].self, from: data)
                    completionHandler(toDos)
                } catch let decoderError {
                    print(decoderError)
                }
            }
        })
        task.resume()
    }
    func fetchLine(compID : Int,  completionHandler: @escaping ([Lines]) -> Void) {
        
        let url = URL(string: domainUrl + "api/lines/"+String(compID))!
        
        let task = URLSession.shared.dataTask(with: url, completionHandler: { (data, response, error) in
            if let error = error {
                print("Error with fetching stops: \(error)")
                return
            }
            
            if let data = data {
                do {
                    let toDos = try JSONDecoder().decode([Lines].self, from: data)
                    completionHandler(toDos)
                } catch let decoderError {
                    print(decoderError)
                }
            }
        })
        task.resume()
    }

    func nextTimeBusLine(stopID : Int,lineID : Int, currentDate : Date, completionHandler: @escaping ([TimeBusLine]) -> Void) {
    
        let unixDate = Int(currentDate.timeIntervalSince1970)
        let url = URL(string: domainUrl + "api/nexttime_bus_line/"+String(stopID)+"/"+String(lineID)+"/"+String(unixDate))!
        
        let task = URLSession.shared.dataTask(with: url, completionHandler: { (data, response, error) in
            if let error = error {
                print("Error with fetching stops: \(error)")
                return
            }
            
            if let data = data {
                do {
                    let toDos = try JSONDecoder().decode([TimeBusLine].self, from: data)
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
    
    func putMethod() {
        let url = URL(string: domainUrl + "api/userbusstatus/")!
        
        // Create model
        struct UploadData: Codable {
            let name: String
            let job: String
        }
        
        // Add data to the model
        let uploadDataModel = UploadData(name: "Nicole", job: "iOS Developer")
        
        // Convert model to JSON data
        guard let jsonData = try? JSONEncoder().encode(uploadDataModel) else {
            print("Error: Trying to convert model to JSON data")
            return
        }
        
        // Create the request
        var request = URLRequest(url: url)
        request.httpMethod = "PUT"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        request.httpBody = jsonData
        URLSession.shared.dataTask(with: request) { data, response, error in
            guard error == nil else {
                print("Error: error calling PUT")
                print(error!)
                return
            }
            guard let data = data else {
                print("Error: Did not receive data")
                return
            }
            guard let response = response as? HTTPURLResponse, (200 ..< 299) ~= response.statusCode else {
                print("Error: HTTP request failed")
                return
            }
            do {
                guard let jsonObject = try JSONSerialization.jsonObject(with: data) as? [String: Any] else {
                    print("Error: Cannot convert data to JSON object")
                    return
                }
                guard let prettyJsonData = try? JSONSerialization.data(withJSONObject: jsonObject, options: .prettyPrinted) else {
                    print("Error: Cannot convert JSON object to Pretty JSON data")
                    return
                }
                guard let prettyPrintedJson = String(data: prettyJsonData, encoding: .utf8) else {
                    print("Error: Could print JSON in String")
                    return
                }
                
                print(prettyPrintedJson)
            } catch {
                print("Error: Trying to convert JSON data to string")
                return
            }
        }.resume()
    }
}
