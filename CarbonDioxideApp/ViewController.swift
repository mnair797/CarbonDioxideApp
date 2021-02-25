//
//  ViewController.swift
//  CarbonDioxideApp
//
//  Created by Meenakshi Nair on 1/14/21.
//

import UIKit
import CoreBluetooth
class ViewController: UIViewController {
    
    
    var centralManager: CBCentralManager!
    var co2Peripheral: CBPeripheral!
    var sleepTime : UInt32 = 300
    var use1503 = false
    var use3001 = true
    
    @IBOutlet weak var mainText: UITextView!
    @IBOutlet weak var lowerLabel: UILabel!
    
    @IBOutlet weak var topLabel: UILabel!
    
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        centralManager = CBCentralManager(delegate: self, queue: nil)
    }
    
}

extension ViewController: CBCentralManagerDelegate {
    func centralManagerDidUpdateState(_ central: CBCentralManager) {
        switch central.state {
        case .unknown:
            print("central.state is .unknown")
        case .resetting:
            print("central.state is .resetting")
        case .unsupported:
            print("central.state is .unsupported")
        case .unauthorized:
            print("central.state is .unauthorized")
        case .poweredOff:
            print("central.state is .poweredOff")
        case .poweredOn:
            print("central.state is .poweredOn")
            centralManager.scanForPeripherals(withServices: nil)
        @unknown default:
            print("central.state is unknown: ",central.self)
        }
    }
    
    func centralManager(_ central: CBCentralManager, didDiscover peripheral: CBPeripheral,
                        advertisementData: [String : Any], rssi RSSI: NSNumber) {
        //print("Peripheral:",peripheral)
        if((peripheral.name?.starts(with: "Aranet")) == true) {
            print("Found Aranet device:",peripheral)
            co2Peripheral = peripheral
            co2Peripheral.delegate = self
            centralManager.stopScan()
            centralManager.connect(co2Peripheral)
        }
        //print("Finished processing device")
    }
    
    func centralManager(_ central: CBCentralManager, didConnect peripheral: CBPeripheral) {
        print("Connected!")
        co2Peripheral.discoverServices([])
        //print("Finished discovery")
    }
    
}

extension ViewController: CBPeripheralDelegate {
    func peripheral(_ peripheral: CBPeripheral, didDiscoverServices error: Error?) {
        guard let services = peripheral.services else { return }
        for service in services {
            // print("Service: ",service)
            if(service.uuid.uuidString.starts(with: "F0CD1400")) {
                peripheral.discoverCharacteristics(nil, for: service)
            }
        }
    }
    
    func peripheral(_ peripheral: CBPeripheral, didDiscoverCharacteristicsFor service: CBService, error: Error?) {
        guard let characteristics = service.characteristics else { return }
        
        for characteristic in characteristics {
            //print("Characteristic: ",characteristic)
            
            if characteristic.properties.contains(.read) {
                //print("Char read \(characteristic.uuid): properties contains .read")
                peripheral.readValue(for: characteristic)
            }
            if characteristic.properties.contains(.notify) {
                //print("Char notify \(characteristic.uuid): properties contains .notify")
                peripheral.setNotifyValue(true, for: characteristic)
            }
        }
    }
    
    func peripheral(_ peripheral: CBPeripheral, didUpdateValueFor characteristic: CBCharacteristic, error: Error?) {
        //print("Unhandled Characteristic UUID: \(characteristic.uuid)")
        guard let characteristicData = characteristic.value else {print("Null characteristic data"); return}
        let byteArray = [UInt8](characteristicData)
        //print(byteArray)
        if(characteristic.uuid.uuidString.starts(with: "F0CD3001")) {
            if(use3001) {
                handleF0CD3001(byteArray: byteArray)
                //peripheral.setNotifyValue(true, for: characteristic)
                let s2 = String(format:"Update in %d secs",sleepTime)
                print(s2)
                DispatchQueue.main.asyncAfter(deadline: .now()+Double(sleepTime)) {
                    print("On the road again...")
                    self.centralManager.connect(self.co2Peripheral)
                    //self.lowerLabel.text = "Fetching..."
                }
            }
            
        }
        if(characteristic.uuid.uuidString.starts(with: "F0CD1503")) {
            if(use1503) {
                handleF0CD1503(byteArray: byteArray)
                //peripheral.setNotifyValue(true, for: characteristic)
                let s2 = String(format:"1503: Update in %d secs",sleepTime)
                print(s2)
                DispatchQueue.main.asyncAfter(deadline: .now()+Double(sleepTime)) {
                    print("1503: On the road again...")
                    self.centralManager.connect(self.co2Peripheral)
                    //self.lowerLabel.text = "Fetching..."
                }
            }
        }
        
        //print("Finished printing")
        //Unhandled Characteristic UUID: F0CD3001-95DA-4F4B-9AC8-AA55D312AF0C
        // [141, 1, 195, 1, 97, 39, 34, 90, 1, 44, 1, 171, 0]
    }
    
    func baToInt(_ b1:UInt8,_ b2:UInt8) ->Int {
        let i1=Int(b1)
        let i2=Int(b2)
        let i = i1+256*i2
        return i
    }
    
    func getCurrentDateTime() -> String {
        let currentDateTime=Date()
        let formatter=DateFormatter()
        formatter.timeStyle = .medium
        formatter.dateStyle = .none
        let dateTimeStr=formatter.string(from: currentDateTime)
        return dateTimeStr
    }
    
    func handleF0CD3001(byteArray: [UInt8]) {
        //print("F0CD3001 shows byte array:",byteArray)
        let c = baToInt(byteArray[0],byteArray[1])
        let t1 = baToInt(byteArray[2],byteArray[3])
        let t2 = Float(t1)/20
        let t = (t2*9/5) + 32
        // let t3 = (t2-32)*5/9
        let p = (baToInt(byteArray[4],byteArray[5]) )/10
        let h = baToInt(byteArray[6],0)
        let b = baToInt(byteArray[7],0)
        let i = baToInt(byteArray[9],byteArray[10])
        let a = baToInt(byteArray[11],byteArray[12])
        sleepTime=UInt32(i-a)
        let cdt = getCurrentDateTime()
        print(getCurrentDateTime(),": 3001 Seeing values: ",c,t,p,h,b,i,a, "with t1 & t2 as",t1,t2)
        let s = String(format:"As of \(cdt)\nCO2 %d ppm\n Temp %.1f F\nPressure %d mbar\nHumidity %d%%\nBattery %d%%",c,t,p,h,b)
        
        mainText.text = s
        if (c<700) {
            mainText.textColor = UIColor.green;
        } else if (c>=700 && c<1200) {
            mainText.textColor = UIColor.orange;
        } else {
            mainText.textColor = UIColor.red;
        }
        print (p)
        //mainText.backgroundColor = .gray
        DispatchQueue.main.async {
            self.mainText.text = s
        }
        GoogleSheetsIntegration.recordSensor(source:"Aranet4",co2:c,timestamp:cdt, tempF:t, pressure:p, humidity:h,battery:b)
        
    }
    
    func handleF0CD1503(byteArray: [UInt8]) {
        //print("F0CD1503 shows byte array:",byteArray)
        let c = baToInt(byteArray[0],byteArray[1])
        let t1 = baToInt(byteArray[2],byteArray[3])
        let t2 = Float(t1)/20
        let t = (t2*9/5) + 32
        let p = (baToInt(byteArray[4],byteArray[5]) )/10
        let h = baToInt(byteArray[6],0)
        let b = baToInt(byteArray[7],0)
        
        //let i = baToInt(byteArray[9],byteArray[10])
        //let a = baToInt(byteArray[11],byteArray[12])
        print(getCurrentDateTime(),": 1503 Seeing values: ",c,t,p,h,b, "with t1 & t2 as",t1,t2)
        GoogleSheetsIntegration.recordSensor(source:"Aranet4",co2:c,timestamp:"Not known 1503", tempF:t, pressure:p, humidity:h, battery: b)
    }
    
    func updateValues() {
        print("Updating values")
    }
    
    func updateStatus(s:String) {
        print("Setting status s =",s)
    }
    
}


