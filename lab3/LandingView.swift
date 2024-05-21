//
//  LandingView.swift
//  lab3
//
//  Created by Viktoriya on 27.04.24.
//

import SwiftUI

struct LandingView: View {
    @EnvironmentObject var authService: AuthService
       
       var body: some View {
           if authService.currentUser == nil {
               LoginView()
           } else {
               ItemListView()
           }
       }
}
