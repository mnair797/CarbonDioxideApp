//
//  DataStore.swift
//  CarbonDioxideApp
//
//  Created by Meenakshi Nair on 3/24/21.
//

import Foundation

class DataStore {
    static var keyCO2 = "keyCO2"
    static var keyTemperature = "keyTemperature"
    static var keyHumidity = "keyHumidity"
    static var keyAranetScreen = "keyAranetScreen"
    static var keySheetData = "keySheetData"
    
    
    static var allKeys = [keyCO2, keyTemperature, keyHumidity, keyAranetScreen, keySheetData]
    
    static func setValue(valueInt: Int, valueKey: String) {
        let stateStore=UserDefaults.standard
        stateStore.set(valueInt, forKey: valueKey)
    }
    
    static func setValue(valueStr: String, valueKey: String) {
        let stateStore=UserDefaults.standard
        stateStore.set(valueStr, forKey: valueKey)
    }
    
    static func setValue(valueFloat: Float, valueKey: String) {
        let stateStore=UserDefaults.standard
        stateStore.set(valueFloat, forKey: valueKey)
    }
    
    static func setValue(valueDouble: Double, valueKey: String) {
        let stateStore=UserDefaults.standard
        stateStore.set(valueDouble, forKey: valueKey)
    }
    
    static func setValue(valueBool: Bool, valueKey: String) {
        let stateStore=UserDefaults.standard
        stateStore.set(valueBool, forKey: valueKey)
    }
    
    static func setValue(valueArray: [Any], valueKey: String) {
        let stateStore=UserDefaults.standard
        stateStore.set(valueArray, forKey: valueKey)
    }
    
    static func getValue(valueKey: String) -> Any? {
        let stateStore=UserDefaults.standard
        return stateStore.value(forKey: valueKey)
    }
    
    static func setCO2(valueInt: Int) {
        setValue(valueInt: valueInt, valueKey: keyCO2)
    }
    
    static func setTemperature(valueFloat: Float) {
        setValue(valueFloat: valueFloat, valueKey: keyTemperature)
    }
    
    static func setHumidity(valueInt: Int) {
        setValue(valueInt: valueInt, valueKey: keyHumidity)
    }
    
    static func setAranetScreen(valueStr: String) {
        setValue(valueStr: valueStr, valueKey: keyAranetScreen)
    }
    
    static func setSheetData(valueArray: [Any]) {
        setValue(valueArray: valueArray, valueKey: keySheetData)
    }
    
    
    static func getCO2() -> Int? {
        return getValue(valueKey: keyCO2) as! Int?
    }
    
    static func getTemperature() -> Float? {
        return getValue(valueKey: keyTemperature) as! Float?
    }
    
    static func getHumidity() -> Int? {
        return getValue(valueKey: keyHumidity) as! Int?
    }
    
    static func getAranetScreen() -> String? {
        return getValue(valueKey: keyAranetScreen) as! String?
    }
    
    static func getSheetData() -> [Any]? {
        return getValue(valueKey: keySheetData) as! [Any]?
    }
    
    static func clearAll() {
        let stateStore = UserDefaults.standard
        for i in allKeys {
            stateStore.removeObject(forKey: i)
        }
    }
    
    static func dumpAllKeys() {
        for i in allKeys {
            let j = getValue(valueKey: i) ?? "Not Found"
            if(i != keySheetData) {
            print("Persistent state: \(i) -> \(j)")
            } else {
                if let j2 = j as? [Any]  {
                    print("Persistent state array: \(i) -> \(j2.count)")
                } else {
                    print("Persistent state. Cast as array failed for key:",i)
                }
            }
        }
    }
    
    
}
