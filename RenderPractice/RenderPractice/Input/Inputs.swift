//
//  Inputs.swift
//  RenderPractice
//
//  Created by Bene Róbert on 2024. 02. 16..
//

import GameController

struct Point {
    var x: Float = 0.0
    var y: Float = 0.0
    static let zero = Point(x: 0, y: 0)
}

class InputHandler {
    static let shared = InputHandler()
    
    var leftMouseDown = false
    var mouseDelta = Point.zero
    var mouseScroll = Point.zero
    
    private init() {
        let center = NotificationCenter.default
        center.addObserver(forName: .GCMouseDidConnect,
                           object: nil,
                           queue: nil) { notification in
            let mouse = notification.object as? GCMouse
            
            mouse?.mouseInput?.leftButton.pressedChangedHandler = { _, _, pressed in
                self.leftMouseDown = pressed
            }
            
            mouse?.mouseInput?.mouseMovedHandler = { _, deltaX, deltaY in
                self.mouseDelta = Point(x: deltaX, y: deltaY)
            }
            
            mouse?.mouseInput?.scroll.valueChangedHandler = { _, xValue, yValue in
                self.mouseScroll.x = xValue
                self.mouseScroll.y = yValue
            }
        }
    }
}
