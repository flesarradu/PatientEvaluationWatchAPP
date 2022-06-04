//
//  PatientEvaluationWatchAPPApp.swift
//  PatientEvaluationWatchAPP WatchKit Extension
//
//  Created by AdminGuest on 03.06.22.
//

import SwiftUI


@main
struct PatientEvaluationWatchAPPApp: App {
    @SceneBuilder var body: some Scene {
        WindowGroup {
            NavigationView {
                ContentView()
            }
        }
        
        WKNotificationScene(controller: NotificationController.self, category: "myCategory")
        
    }
}
