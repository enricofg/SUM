//
//  Structures.swift
//  SUM
//
//  Created by Jose Machado on 24/12/2021.
//

import Foundation


struct Bus: Decodable {
    var Bus_Name: String
    var Bus_Number: Int
    var Bus_Capacity: Int
    var Client_Id: Int
}

struct Stops: Decodable {
    var Stop_Id: Int
    var Stop_Name: String
    var Longitude: Double
    var Latitude: Double
    var Line_Id: Int
    var sc: [Schedule]
}

struct Schedule: Decodable {
    var Schedule_Weekday: String
    var Schedule_Time: String
}


struct Lines: Decodable {
    var Line_Id: Int
    var Line_Number: Int
    var Line_Name: String
    var Line_IsActive: Bool
}
