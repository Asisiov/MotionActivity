//
//  Created by Sisov on 5/7/19.
//  Copyright © 2019 Provision Lab. All rights reserved.
//

import Foundation

// MARK: Enums
extension Activity {
  enum ActivityTypes: Int {
    case vehicle    = 0
    case bicycle    = 1
    case foot       = 2
    case still      = 3
    case unknown    = 4
    case tilting    = 5
    case walking    = 7
    case running    = 8
  }
}
