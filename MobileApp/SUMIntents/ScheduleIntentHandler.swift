//
//  ScheduleIntentHandler.swift
//  SUMIntents
//
//  Created by Enrico Florentino Gomes on 13/01/2022.
//

import Foundation
import Intents

class ScheduleIntentHandler:NSObject, ScheduleIntentHandling{

    let networkManager = NetworkManager()
    var selectedBus:Bus?=nil
    var busStop:Stops?=nil
    var busSchedule:StopSchedule?=nil
    
    func handle(intent: ScheduleIntent, completion: @escaping (ScheduleIntentResponse) -> Void) {
        //get bus
        networkManager.fetchBus(busNumber: intent.busId?.intValue )  { [weak self] (_bus) in
            self?.selectedBus=_bus.first
            DispatchQueue.main.async { [self] in
                //get first stop
                self!.networkManager.fetchStops { [weak self] (stops) in
                    DispatchQueue.main.async { [self] in
                        self!.busStop=stops.first
                        
                        //get first schedule for stop
                        self!.networkManager.fetchStopsSchedule(compID: self!.busStop!.Stop_Id){[weak self] (stopsschedules) in
                            self!.busSchedule=stopsschedules.first?.StopSchedule.first
                            DispatchQueue.main.async {
                                if self!.busSchedule != nil {
                                    completion(.success(schedule: "The bus \(self!.selectedBus?.Bus_Name ?? "") with id \(intent.busId?.intValue ?? 9999) will stop at the \(self!.busStop?.Stop_Name ?? "") at \(self!.busSchedule?.Schedule_Time ?? "")."))
                                } else {
                                    completion(.success(schedule: "No bus schedule information could be found."))
                                }
                            }
                        }
                    }
                }
            }
        }
    }
    
    func resolveBusId(for intent: ScheduleIntent, with completion: @escaping (ScheduleBusIdResolutionResult) -> Void) {
        guard let busId = intent.busId?.intValue else {
           completion(ScheduleBusIdResolutionResult.needsValue())
           return
        }
        completion(ScheduleBusIdResolutionResult.success(with: busId))
    }
}

