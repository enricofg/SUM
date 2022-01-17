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
    var timeBusLine:TimeBusLine?=nil
    
    func handle(intent: ScheduleIntent, completion: @escaping (ScheduleIntentResponse) -> Void) {
        networkManager.nextTimeBusLine(stopID: intent.stopId?.intValue ?? 0, lineID: intent.lineId?.intValue ?? 0, currentDate: Date()) { [weak self] (timeBusLine) in
            self?.timeBusLine=timeBusLine.first
            DispatchQueue.main.async { [self] in
                if self!.timeBusLine != nil {
                    completion(.success(schedule: "The bus \(self!.timeBusLine?.Bus_Name ?? "") will stop at the \( self!.timeBusLine?.Stop_Name ?? "") at \(self!.timeBusLine?.Schedule_Time ?? "")."))
                } else {
                    completion(.success(schedule: "No bus schedule information could be found."))
                }
            }
        }
    }
    
    func resolveLineId(for intent: ScheduleIntent, with completion: @escaping (ScheduleLineIdResolutionResult) -> Void) {
        guard let lineId = intent.lineId?.intValue else {
           completion(ScheduleLineIdResolutionResult.needsValue())
           return
        }
        completion(ScheduleLineIdResolutionResult.success(with: lineId))
    }
    
    func resolveStopId(for intent: ScheduleIntent, with completion: @escaping (ScheduleStopIdResolutionResult) -> Void) {
        guard let stopId = intent.stopId?.intValue else {
           completion(ScheduleStopIdResolutionResult.needsValue())
           return
        }
        completion(ScheduleStopIdResolutionResult.success(with: stopId))
    }
}

