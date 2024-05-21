//
//  ContentView.swift
//  lab3
//
//  Created by Viktoriya on 25.04.24.
//

import SwiftUI
import CoreData
import Firebase

struct LoginView: View {
    @State private var name: String = ""
    @State private var surname: String = ""
    @State private var email: String = ""
    @State private var password: String = ""
    @State private var isRegistrated: Bool = true
    @EnvironmentObject var authService: AuthService
    @StateObject var dataService = DataService()
    
    var body: some View {
        content
    }
    
    var content: some View{
        ZStack {
            LinearGradient(gradient: Gradient(colors: [Color.white, Color(red: 255/255, green: 184/255, blue: 78/255)]),
                                   startPoint: .top,
                                   endPoint: .bottom)
                        .edgesIgnoringSafeArea(.all)
            VStack(spacing: 0){
                if isRegistrated {
                    ZStack {
                        Rectangle()
                                    .frame(height: 250)
                                    .foregroundColor(.orange)
                                .padding(.top, 20)
                                .cornerRadius(20)
                                .padding(.top, -20)
                                
                                Image("logo")
                                    .resizable()
                                    .aspectRatio(contentMode: .fit)
                                    .frame(width: 175, height: 175)
                                    .padding()
                            }
                } else {
                    ZStack {
                        Rectangle()
                                    .frame(height: 150)
                                    .foregroundColor(.orange)
                                .padding(.top, 20)
                                .cornerRadius(20)
                                .padding(.top, -20)
                                
                                Image("logo2")
                                    .resizable()
                                    .aspectRatio(contentMode: .fit)
                                    .frame(width: 90, height: 90)
                                    .padding()
                    }
                }
                Spacer().frame(height: 40)
            
                TextField("Enter email", text: $email)
                            .padding()
                            .frame(width: 320, height: 50)
                            .background(Color.white)
                            .cornerRadius(20)
                            .padding(.bottom, 30)
                        
                SecureField("Enter password", text: $password)
                            .padding()
                            .frame(width: 320, height: 50)
                            .background(Color.white)
                            .cornerRadius(20)
                            .padding(.bottom, 30)
                if(isRegistrated){
                    Button(action: {
                            login()
                        }) {
                            Text("Login")
                                .font(.system(size: 25))
                                .foregroundColor(.white)
                                .frame(width: 320, height: 50)
                                .background(Color.orange)
                                .cornerRadius(25)
                        }.padding(.bottom, 50)
                        
                    Text("Don't have any account? Register now")
                            .foregroundColor(Color(red: 163/255, green: 97/255, blue: 0/255))
                            .font(.system(size: 16))
                            .onTapGesture {
                                isRegistrated = false
                                print("View Tapped")
                    }
                    
                }
                else{
                    TextField("Enter name", text: $name)
                                .padding()
                                .frame(width: 320, height: 50)
                                .background(Color.white)
                                .cornerRadius(20)
                                .padding(.bottom, 30)
                            
                    TextField("Enter surname", text: $surname)
                                .padding()
                                .frame(width: 320, height: 50)
                                .background(Color.white)
                                .cornerRadius(20)
                                .padding(.bottom, 30)
                    Button(action: {
                            register()
                        }) {
                            Text("Register")
                                .font(.system(size: 25))
                                .foregroundColor(.white)
                                .frame(width: 320, height: 50)
                                .background(Color.orange)
                                .cornerRadius(25)
                        }.padding(.bottom, 50)
                        
                    Text("Have already member? Login now")
                            .foregroundColor(Color(red: 163/255, green: 97/255, blue: 0/255))
                            .font(.system(size: 16))
                            .onTapGesture {
                                isRegistrated = true
                                print("View Tapped")
                    }
                
                }
                
            }.frame(maxWidth:.infinity, maxHeight: .infinity, alignment: .topLeading)
        }
    }
    func register(){
        if(!email.isEmpty && !password.isEmpty){
            Auth.auth().createUser(withEmail: email, password: password){
                result, error in
                if error != nil{
                    print(error!.localizedDescription)
                }
                else{
                    let myUser = MyUser(name: name, surname: surname, gender: nil, email: email, birthdate: nil, favRecipe: nil, address: nil, phone: nil, vegeterian: nil, skill: nil)
                    dataService.saveUser(user: myUser, userId: authService.currentUser!)
                }
            }
        }
    }
    func login(){
        authService.signIn(email: email, password: password)
        { success in
                        if success {
                            DispatchQueue.main.async {
                                            UIApplication.shared.windows.first?.rootViewController = UIHostingController(rootView: LandingView().environmentObject(authService))
                                        }
                        } else {
                            //error = "Неправильный email или пароль"
                        }
                    }
    }
        
}

struct LoginView_Previews: PreviewProvider {
    static var previews: some View {
        LoginView()
    }
}

