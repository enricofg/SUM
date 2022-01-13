//
//  ScheduleIntentHandler.swift
//  SUMIntents
//
//  Created by Enrico Florentino Gomes on 13/01/2022.
//

import Foundation
import Intents

class ScheduleIntentHandler:NSObject, ScheduleIntentHandling{
    
    func handle(intent: ScheduleIntent, completion: @escaping (ScheduleIntentResponse) -> Void) {
        completion(.success(schedule: "Rua António Gaspar Serrano at 07:30:00")) //TODO: get real information
    }
    
    
}
