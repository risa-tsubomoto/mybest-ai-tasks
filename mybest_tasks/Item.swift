//
//  Item.swift
//  mybest_tasks
//
//  Created by 坪本梨沙 on 2025/11/21.
//

import Foundation
import SwiftData

@Model
final class Item {
    var timestamp: Date
    
    init(timestamp: Date) {
        self.timestamp = timestamp
    }
}
