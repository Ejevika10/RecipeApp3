//
//  lab3App.swift
//  lab3
//
//  Created by Viktoriya on 25.04.24.
//

import SwiftUI
import FirebaseCore

@main
struct lab3App: App {
    @StateObject var authService = AuthService()
        
        init() {
            FirebaseApp.configure()
        }
        
        var body: some Scene {
            WindowGroup {
                ContentView()
                    .environmentObject(authService)
            }
        }
}
struct ContentView: View {
    @EnvironmentObject var authService: AuthService
    
    var body: some View {
        LandingView()
    }
}
