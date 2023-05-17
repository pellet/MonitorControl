//
//  OSCHandler.swift
//  MonitorControl
//
//  Created by pellet on 1/5/2023.
//  Copyright © 2023 MonitorControl. All rights reserved.
//

import Foundation
import SwiftOSC
import AudioToolbox

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
  
  func setVol(vol: Float32) {
    var defaultOutputDeviceID = AudioDeviceID(0)
    var defaultOutputDeviceIDSize = UInt32(MemoryLayout.size(ofValue: defaultOutputDeviceID))

    var getDefaultOutputDevicePropertyAddress = AudioObjectPropertyAddress(
        mSelector: kAudioHardwarePropertyDefaultOutputDevice,
        mScope: kAudioObjectPropertyScopeGlobal,
        mElement: AudioObjectPropertyElement(kAudioObjectPropertyElementMaster))

    let status1 = AudioObjectGetPropertyData(
        AudioObjectID(kAudioObjectSystemObject),
        &getDefaultOutputDevicePropertyAddress,
        0,
        nil,
        &defaultOutputDeviceIDSize,
        &defaultOutputDeviceID)

    var volume = vol//Float32(0.50) // 0.0 ... 1.0
    var volumeSize = UInt32(MemoryLayout.size(ofValue: volume))

    var volumePropertyAddress = AudioObjectPropertyAddress(
      mSelector: kAudioHardwareServiceDeviceProperty_VirtualMainVolume,
        mScope: kAudioDevicePropertyScopeOutput,
        mElement: kAudioObjectPropertyElementMaster)

    let status2 = AudioObjectSetPropertyData(
        defaultOutputDeviceID,
        &volumePropertyAddress,
        0,
        nil,
        volumeSize,
        &volume)
    
    volume = Float32(0.0)
    let status3 = AudioObjectGetPropertyData(
        defaultOutputDeviceID,
        &volumePropertyAddress,
        0,
        nil,
        &volumeSize,
        &volume)
  }
    
  func didReceive(_ message: OSCMessage){
    if let integer = message.arguments[0] as? Int {
        print("Received int \(integer)")
    } else if let float = message.arguments[0] as? Float {
      let accuracy = Float(100)
      let rounded = round(float*accuracy)
      if rounded != self.last {
        
        self.last = rounded
        DispatchQueue.main.async {
          let setty = rounded/accuracy/100
          print("setting display to: \(setty)")
          _ = self.setSlider?(setty)
                
          print("setting volume to: \(setty)")
          self.setVol(vol: setty)
        }
        
        
      }
    
    }
    else {
        print(message)
    }
  }
}
