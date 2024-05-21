//
//  AuthService.swift
//  lab3
//
//  Created by Viktoriya on 26.04.24.
//

import Foundation
import Combine
import FirebaseAuth

class AuthService: ObservableObject {
    @Published var currentUser: String?
    private var authStateListenerHandle: AuthStateDidChangeListenerHandle?
    private var cancellables = Set<AnyCancellable>()
    
    init() {
        listenForAuthChanges()
    }
    
    func listenForAuthChanges() {
            authStateListenerHandle = Auth.auth().addStateDidChangeListener { auth, user in
                if let firebaseUser = user {
                    self.currentUser = firebaseUser.uid
                } else {
                    self.currentUser = nil
                }
            }
        }
    
    func signIn(email: String, password: String, completion: @escaping (Bool) -> Void) {
            Auth.auth().signIn(withEmail: email, password: password) { result, error in
                if let error = error {
                    print("Error signing in: \(error.localizedDescription)")
                    completion(false)
                } else {
                    completion(true)
                }
            }
        }
        
        func register(email: String, password: String, completion: @escaping (Bool) -> Void) {
            Auth.auth().createUser(withEmail: email, password: password) { result, error in
                if let error = error {
                    print("Error signing up: \(error.localizedDescription)")
                    completion(false)
                } else {
                    if let uid = result?.user.uid {
                        //DatabaseService(uid: uid).createUserData()
                    }
                }
            }
        }
        
        func signOut() {
            do {
                try Auth.auth().signOut()
            } catch {
                print("Error signing out: \(error.localizedDescription)")
            }
        }
        
        deinit {
            if let handle = authStateListenerHandle {
                Auth.auth().removeStateDidChangeListener(handle)
            }
        }
}
