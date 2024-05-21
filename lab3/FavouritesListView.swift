//
//  ItemListView.swift
//  lab3
//
//  Created by Viktoriya on 26.04.24.
//

import SwiftUI
import Firebase

struct FavouritesListView: View {
    @State private var items: [Item] = []
    @State private var favs: [String] = []
    @Environment(\.presentationMode) var presentationMode: Binding<PresentationMode>
    @EnvironmentObject var authService: AuthService
    @StateObject var dataService = DataService()
    
    var body: some View {
        NavigationView{
            VStack(spacing: 0){
                favouritesListAppBar()
                getFavouritesList()
            }.navigationBarHidden(true)
        }.navigationBarHidden(true)
    }
        
    func getFavouritesList() -> some View {
        return
        LinearGradient(gradient: Gradient(colors: [Color.white, Color(red: 255/255, green: 184/255, blue: 78/255)]),
                                           startPoint: .top,
                                           endPoint: .bottom)
        .edgesIgnoringSafeArea(.vertical).overlay(
            
            List(items) { item in
            if favs.contains(item.id) {
                ItemInList(item: item).listRowBackground(
                    RoundedRectangle(cornerRadius: 20)
                        .background(.clear)
                        .foregroundColor(.white)
                        .padding(
                            EdgeInsets(
                                top: 10,
                                leading: 0,
                                bottom: 10,
                                trailing: 0
                            )
                        )
                )
                .listRowSeparator(.hidden)
            }
            }
                .onAppear {
                    UITableView.appearance().backgroundColor = .clear
                    readDataFromFirebase()
                }
        )
    }
    
    func readDataFromFirebase() {
        let ref = Database.database().reference().child("items")
        ref.observe(.value) { snapshot in
            var newItems: [Item] = []
            for case let child as DataSnapshot in snapshot.children {
                if let objectData = child.value as? [String: Any]{
                    let object = Item.fromDictionary(objectData)
                    newItems.append(object!)
                }
            }
            self.items = newItems
        }
        
        let ref1 = Database.database().reference().child("users/\(authService.currentUser!)/favourites")
        ref1.observe(.value) { snapshot in
            var newFavs: [String] = []
            for case let child as DataSnapshot in snapshot.children{
                if let objectData = child.value as? [String: Any]{
                    let object = objectData["itemId"] as! String
                    newFavs.append(object)
                }
            }
            self.favs = newFavs
        }
        
    }
    func favouritesListAppBar() -> some View {
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
                    Text("Favourites")
                                   .font(.title)
                                   .foregroundColor(.white)
                                   .fontWeight(.bold)
                                   .padding(.top, 10)
                    Spacer()
                    
                    Spacer().frame(width: 50)
                }
            }
        
    }
}
