//
//  AppIntent.swift
//  SUM
//
//  Created by Enrico Florentino Gomes on 13/01/2022.
//

import Foundation
import Intents

class AppIntent{
    
    class func allowSiri(){
        INPreferences.requestSiriAuthorization{ status in
            switch status {
            case .notDetermined,
                 .restricted,
                 .denied:
                print("Siri needs access.") //TODO: warn user that Siri needs access
            case .authorized:
                print("Siri has access.")
            @unknown default:
                break;
            }
        }
    }
    
    class func schedule(){
        let intent = ScheduleIntent()
        intent.suggestedInvocationPhrase = "Get bus schedule"
        
        let interaction = INInteraction(intent: intent, response: nil)
        interaction.donate { error in
            if let error = error as NSError? {
                print("Interaction donation failed: \(error.description)")
            } else {
                print("Interaction donated successfully.")
            }
        }
        
    }
}
