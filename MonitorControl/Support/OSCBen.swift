//
//  OSCHandler.swift
//  MonitorControl
//
//  Created by pellet on 1/5/2023.
//  Copyright © 2023 MonitorControl. All rights reserved.
//

import Foundation
import SwiftOSC

class OSCBen
{
  
  let server = OSCServer(address: "", port: 16342)
  
  init(setSlider: @escaping (Float) -> Void) {
    
    class OSCHandler: OSCServerDelegate {
      var setSlider: (Float) -> Void
      init(setSlider: @escaping (Float) -> Void) {
        self.setSlider = setSlider
        self.last = -1
      }
      
      var last: Float
        
        func didReceive(_ message: OSCMessage){
            if let integer = message.arguments[0] as? Int {
                print("Received int \(integer)")
            } else if let float = message.arguments[0] as? Float {
              let accuracy = Float(100)
              let rounded = round(float*accuracy)
              if rounded != self.last {
                print("setting display to: \(rounded/accuracy)%")
                self.last = rounded
                DispatchQueue.main.async {
                  _ = self.setSlider(rounded/accuracy/100)
                }
              }
            
            }
            else {
                print(message)
              
            }
        }
    }
    server.delegate =  OSCHandler(setSlider: setSlider)
    //create OSC server
    self.server.start()
    print("created osc server")
  }
}
