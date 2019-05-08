//
//  Created by Aleksandr Sisiov on 2/11/19.
//  Copyright © 2019 Provision Lab. All rights reserved.
//

import Foundation

protocol ActivityProtocol {
  
  typealias ActivityHandle = (_ activityModel: Activity?, _ manager: ActivityProtocol?) -> ()
  
  var canUseBarometer: Bool { get }
  
  func collectActivity(handle: @escaping ActivityHandle)
  func stop()
}
