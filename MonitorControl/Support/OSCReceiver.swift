//
//  OSCHandler.swift
//  MonitorControl
//
//  Created by pellet on 1/5/2023.
//  Copyright © 2023 MonitorControl. All rights reserved.
//

import Foundation
import SwiftOSC

class OSCReceiver: OSCServerDelegate
{
  let server = OSCServer(address: "", port: 16342)
  
  var last: Float = -1
  
  public var setSlider: ((Float) -> Void)?
  
  public init()
  {
    server.delegate = self
    //create OSC server
    self.server.start()
    print("created osc server")
  }
    
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
          _ = self.setSlider?(rounded/accuracy/100)
        }
      }
    
    }
    else {
        print(message)
    }
  }
}
