//
//  Constant.swift
//  AlamofireExample
//
//  Created by Bhavesh Chavda on 22/01/20.
//  Copyright © 2020 BhaveshChavda. All rights reserved.
//

import Foundation
import  UIKit

let APPDELEGATE = UIApplication.shared.delegate as! AppDelegate

let MAIN_SCREEN = UIScreen.main
let SCREEN_WIDTH: CGFloat = MAIN_SCREEN.bounds.width
let SCREEN_HEIGHT = MAIN_SCREEN.bounds.height
let SCREEN_SCALE: CGFloat = MAIN_SCREEN.bounds.width / 320
let toastOnScreenTime = 2.0 // seconds
// MARK: - Print
func PRINT(_ data: Any) {
    #if DEBUG
    print(data)
    #endif
}


