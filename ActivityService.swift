//
//  Created by Aleksandr Sisiov on 2/11/19.
//  Copyright © 2019 Provision Lab. All rights reserved.
//

import CoreMotion

class ActivityService {
  // MARK: -
  // MARK: Private properties
  private let activityManager = CMMotionActivityManager()
  private let altimeter = CMAltimeter()
  private var handle:ActivityHandle? = nil
  private var motionActivity: CMMotionActivity?
  
  // MARK: -
  // MARK: Read-only
  var canUseBarometer: Bool { return CMAltimeter.isRelativeAltitudeAvailable() }
  
  // MARK: -
  // MARK: Deinitializations
  deinit {
    stop()
  }
}

// MARK: -
// MARK: Activity protocol
extension ActivityService: ActivityProtocol {
  func collectActivity(handle: @escaping ActivityHandle) {
    self.handle = handle
    startActivityUpdates()
    startAltimeter()
  }
  
  func stop() {
    activityManager.stopActivityUpdates()
    altimeter.stopRelativeAltitudeUpdates()
  }
}

// MARK: -
// MARK: Private
private extension ActivityService {
  
  func startActivityUpdates() {
    let activityManagerQueue = OperationQueue()
    activityManagerQueue.qualityOfService = .background
    
    activityManager.startActivityUpdates(to: activityManagerQueue, withHandler: { [weak self] (activity) in
      self?.motionActivity = activity
    })
  }

  func activityType(_ act: CMMotionActivity? ) -> Activity.ActivityTypes {
    guard let activity = act else { return .unknown }
    if activity.automotive { return .vehicle }
    if activity.cycling { return .bicycle }
    if activity.running { return .running }
    if activity.walking { return .walking }
    if activity.stationary { return .still }
    
    return .unknown
  }
  
  func startAltimeter() {

    if !canUseBarometer {
      print("Barometer is not available on this device...")
      return
    }
    
    let altimeterQueue = OperationQueue()
    altimeterQueue.qualityOfService = .background
    
    altimeter.startRelativeAltitudeUpdates(to: altimeterQueue, withHandler: { [weak self] (altitudeData, error) in
      if let error = error {
        print("Altimeter error...")
        NotificationCenter.default.post(name: .ShowGlobalError, object: error)
        return
      }
      
      self?.proccessAltitude(altitudeData: altitudeData)
    })
  }
  
  func proccessAltitude(altitudeData: CMAltitudeData?) {
    guard let data = altitudeData else { return }
    guard let motion = motionActivity else { return }
    
    let timestamp = data.timestamp
    let altitude = data.relativeAltitude.intValue
    let pressure = data.pressure.intValue
    let type = activityType(motion)
    let confidence = motion.confidence.rawValue
    let time = motion.startDate.toMillis()!
    
    handle?(Activity(activityType: type, pressure: pressure,
                    altitude: altitude, timestamp: timestamp,
                    confidence: confidence, time: time),
            self)
  }
}
