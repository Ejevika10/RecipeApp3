//
//  ProfileView.swift
//  lab3
//
//  Created by Viktoriya on 28.04.24.
//

import SwiftUI

struct ProfileView: View {
    //let userId: String
    @Environment(\.presentationMode) var presentationMode: Binding<PresentationMode>
    
    @EnvironmentObject var authService: AuthService
    @StateObject var dataService = DataService()
    @State var myUser: MyUser? = nil
    @State private var name: String = ""
    @State private var surname: String = ""
    @State private var email: String = ""
    @State private var address: String = ""
    @State private var phone: String = ""
    @State private var favRec: String = ""
    @State private var gender: Bool = false
    @State private var vegeterian: Bool = false
    @State private var skill: Int = 0
    @State private var birthdate = Date.now
    
    var body: some View {
        NavigationView{
            VStack(spacing: 0){
                profileAppBar()
                getProfileInfo()
            }.navigationBarHidden(true)
        }.navigationBarHidden(true)
            .onAppear{
                dataService.getUser(userId: authService.currentUser!) { value in
                    DispatchQueue.main.async {
                        self.myUser = value
                        name = myUser?.name ?? ""
                        surname = myUser?.surname ?? ""
                        email = myUser?.email ?? ""
                        address = myUser?.address ?? ""
                        phone = myUser?.phone ?? ""
                        favRec = myUser?.favRecipe ?? ""
                        gender = myUser?.gender ?? false
                        vegeterian = myUser?.vegeterian ?? false
                        skill = myUser?.skill ?? 1
                        let dateFormatter = DateFormatter()
                        dateFormatter.dateFormat = "dd.MM.yyyy"
                        birthdate = dateFormatter.date(from: myUser?.birthdate ?? "") ?? Date.now
                    }
                }
            }
    }
    func getProfileInfo() -> some View {
        return
        LinearGradient(gradient: Gradient(colors: [Color.white, Color(red: 255/255, green: 184/255, blue: 78/255)]),
                                           startPoint: .top,
                                           endPoint: .bottom)
        .edgesIgnoringSafeArea(.vertical).overlay(
        
            VStack{
                HStack {
                        Text("Name")
                            .foregroundColor(.black)
                            .font(.system(size: 20))
                            .fontWeight(.bold)
                            .padding(10)
                            .frame(width: 150)
                        
                        TextField("Name", text: $name)
                            .foregroundColor(.black)
                            .font(.system(size: 20))
                            .padding(10)
                    }
                    .frame(height: 50)
                HStack {
                        Text("Surname")
                            .foregroundColor(.black)
                            .font(.system(size: 20))
                            .fontWeight(.bold)
                            .padding(10)
                            .frame(width: 150)
                        
                        TextField("Surname", text: $surname)
                            .foregroundColor(.black)
                            .font(.system(size: 20))
                            .padding(10)
                    }
                    .frame(height: 50)
                HStack {
                    Text("Birthdate")
                            .foregroundColor(.black)
                            .font(.system(size: 20))
                            .fontWeight(.bold)
                            .padding(10)
                            .frame(width: 90)
                        
                    DatePicker("Please enter a date", selection: $birthdate, displayedComponents: .date).labelsHidden().padding(10)
                    }
                    .frame(height: 50)
                HStack {
                        Text("Gender")
                            .foregroundColor(.black)
                            .font(.system(size: 20))
                            .fontWeight(.bold)
                            .padding(10)
                            .frame(width: 150)
                        
                    Picker(selection: $gender, label: Text("Gender")){
                        Text("Male").tag(true).font(.system(size: 25))
                        Text("Female").tag(false).font(.system(size: 25))
                    }.pickerStyle(.segmented)
                            .padding(10)
                    }
                    .frame(height: 50)
                
                        
                HStack {
                        Text("Email")
                            .foregroundColor(.black)
                            .font(.system(size: 20))
                            .fontWeight(.bold)
                            .padding(10)
                            .frame(width: 150)
                        
                        TextField("Email", text: $email)
                            .foregroundColor(.black)
                            .font(.system(size: 20))
                            .padding(10)
                    }
                    .frame(height: 50)
                HStack {
                        Text("Address")
                            .foregroundColor(.black)
                            .font(.system(size: 20))
                            .fontWeight(.bold)
                            .padding(10)
                            .frame(width: 150)
                        
                        TextField("Address", text: $address)
                            .foregroundColor(.black)
                            .font(.system(size: 20))
                            .padding(10)
                    }
                    .frame(height: 50)
                HStack {
                        Text("Phone")
                            .foregroundColor(.black)
                            .font(.system(size: 20))
                            .fontWeight(.bold)
                            .padding(10)
                            .frame(width: 150)
                        
                        TextField("Phone", text: $phone)
                            .foregroundColor(.black)
                            .font(.system(size: 20))
                            .padding(10)
                    }
                    .frame(height: 50)
                HStack {
                    Text("Vegeterian")
                            .foregroundColor(.black)
                            .font(.system(size: 20))
                            .fontWeight(.bold)
                            .padding(10)
                            .frame(width: 150)
                        
                    Picker(selection: $vegeterian, label: Text("Vegeterian")){
                        Text("Yes").tag(true).font(.system(size: 25))
                        Text("No").tag(false).font(.system(size: 25))
                    }.pickerStyle(.segmented)
                            .padding(10)
                    }
                    .frame(height: 50)
                HStack {
                    Text("Skill")
                            .foregroundColor(.black)
                            .font(.system(size: 20))
                            .fontWeight(.bold)
                            .padding(10)
                            .frame(width: 90)
                        
                    Picker(selection: $skill, label: Text("Vegeterian")){
                        Text("easy").tag(1).font(.system(size: 25))
                        Text("medium").tag(2).font(.system(size: 25))
                        Text("hard").tag(3).font(.system(size: 25))
                    }.pickerStyle(.segmented)
                            .padding(10)
                    }
                    .frame(height: 50)
                HStack {
                        Text("Favourite recipe")
                            .foregroundColor(.black)
                            .font(.system(size: 20))
                            .fontWeight(.bold)
                            .padding(10)
                            .frame(width: 150)
                        
                        TextField("Favourite recipe", text: $favRec)
                            .foregroundColor(.black)
                            .font(.system(size: 20))
                            .padding(10)
                    }
                    .frame(height: 50)
            
            }
        )
    }
           
    func profileAppBar() -> some View {
        return
            ZStack {
                Rectangle()
                            .frame(height: 80)
                            .foregroundColor(.orange)
                            .padding(.top,20)
                        .cornerRadius(20)
                        .padding(.top, -20)
                        
                HStack{
                    Spacer().frame(width: 10)
                    Button(action: {
                        self.presentationMode.wrappedValue.dismiss()
                    }) {
                                            Image(systemName: "arrow.left")
                                                .foregroundColor(.white)
                                                .font(.title)
                                        }
                    Spacer()
                    Text("Profile")
                                   .font(.title)
                                   .foregroundColor(.white)
                                   .fontWeight(.bold)
                                   .padding(.top, 10)
                    Spacer()
                    
                    Button(action: {
                        saveMyUser()
                    }) {
                                            Image(systemName: "square.and.arrow.down")
                                                .foregroundColor(.white)
                                                .font(.title)
                                        }
                    Spacer().frame(width: 10)
                }
            }
    }
    func saveMyUser(){
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "dd.MM.yyyy"
        
        let newUser = MyUser(name: name, surname: surname, gender: gender, email: email, birthdate: dateFormatter.string(from: birthdate), favRecipe: favRec, address: address, phone: phone, vegeterian: vegeterian, skill: skill)
        dataService.saveUser(user: newUser, userId: authService.currentUser!)
    }
    
}

