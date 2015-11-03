//
//  NSNotificationCenterKeys.swift
//  On The Map
//
//  Created by David Fierstein on 10/14/15.
//  Copyright (c) 2015 David Fierstein. All rights reserved.
//

import Foundation

// Globally define a "special notification key" constant that can be broadcast / tuned in to... used to tell table and map views when to refresh
let refreshNotificationKey = "refresh_notification_key"
let segueNotificationKey = "segue_notification_key"
let facebookErrorNotificationKey = "facebook_error_notification_key"
