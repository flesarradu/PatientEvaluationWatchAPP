//
//  ContentView.swift
//  PatientEvaluationWatchAPP WatchKit Extension
//
//  Created by AdminGuest on 03.06.22.
//

import SwiftUI
import CoreMotion
import WatchKit
import UIKit

class AccelerometerDataRetriever{
    var x: Double
    var y: Double
    var z: Double
    
    var accTimer : Timer?
    
    var data: [String] = []
    let motionManager = CMMotionManager()
    
    init(){
        motionManager.startAccelerometerUpdates()
        x=0
        y=0
        z=0
    }
    func stopAccelerometer() {
      accTimer?.invalidate()
      accTimer = nil
    }
    func startAccelerometer () {
        guard accTimer == nil else { return }
        self.data = []
        accTimer = Timer.scheduledTimer(withTimeInterval: 0.04, repeats: true){_ in
            if let data = self.motionManager.accelerometerData {
                self.x = data.acceleration.x
                self.y = data.acceleration.y
                self.z = data.acceleration.z
                let d = "x " + String(self.x) + ", y " + String(self.y) + ", z " + String(self.z)
                self.data.append(d)
            }
        }
    }
    
    
    func getX() -> Double{
        return self.x
    }
    
    func getY()-> Double{
        return self.y
    }
    
    func getZ()-> Double{
        return self.z
    }
    
    
    @IBAction func postHTTP(data: [String], patient: Int) {
        data.forEach{
            let store = [
                  "user": "patient\(patient)",
                  "message": $0 ] as [String : Any]
            do {
                let jsonData = try? JSONSerialization.data(withJSONObject: store, options: JSONSerialization.WritingOptions.prettyPrinted)

                    var request = URLRequest(url: URL(string: "https://rest-apiproiectutcn20220604121538.azurewebsites.net/api/WatchMessages")!)
                    request.setValue("application/json", forHTTPHeaderField: "Content-Type")

                    request.httpMethod = "POST"
                    request.httpBody = jsonData
                    let task = URLSession.shared.dataTask(with: request) { data, response, error in
                        guard let data = data, error == nil else {
                            // check for fundamental networking error
                            print("error=\(String(describing: error))")
                            return
                        }

                        if let httpStatus = response as? HTTPURLResponse, httpStatus.statusCode != 200 {
                            // check for http errors
                            print("statusCode should be 200, but is \(httpStatus.statusCode)")
                            print("response = \(String(describing: response))")
                        }

                        do {
                            if let json = try JSONSerialization.jsonObject(with: data, options: .mutableContainers) as? [String: Any] {
                                print(json)

                                DispatchQueue.main.async {
                                    print("Post request sent successfully")
                                }
                            }
                        } catch let error {
                            print(error.localizedDescription)
                        }
                    }
                    task.resume()
            }
        }
    }

}








struct ContentView: View {
    @State var message = "Start"
    @State var data = ""
    @State var running = false
    let acc = AccelerometerDataRetriever()
        
    @State private var patient = 0.0
    @State private var isEditing = false
    var body: some View {
        ScrollView{
            Text(data).padding()
            Slider(value: $patient,
                    in: 0...100,
                    step: 1,
                    onEditingChanged: {editing in
                        isEditing = editing
                    
                    }
                    
            )
            Text("\((Int)(patient))").foregroundColor(isEditing ? .red : .blue)
            Button(message){
                if running {
                    self.message="Start"
                    self.running=false
                    acc.stopAccelerometer()
                    self.data = "Sending data to server..."
                    acc.postHTTP(data: acc.data, patient: Int(patient))
                    self.data = "Data sent! Recording stopped."
                }
                else {
                    self.message="Stop"
                    self.running=true
                    self.data = "Recording..."
                    acc.startAccelerometer()
                }
                //data = "x " + String(acc.getX()) + ", y " + String(acc.getY()) + ", z " + String(acc.getZ())
                print(acc.data)
            }.padding()
            
        }
        
        
    }
}

	struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
