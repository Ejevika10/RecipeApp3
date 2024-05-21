//
//  ItemView.swift
//  lab3
//
//  Created by Viktoriya on 27.04.24.
//

import SwiftUI
import FirebaseStorage

struct ItemView: View {
    @Environment(\.presentationMode) var presentationMode: Binding<PresentationMode>
    @EnvironmentObject var authService: AuthService
    @StateObject var dataService = DataService()
    let item: Item
    @State private var image: UIImage? = nil
    @State private var images: [UIImage?] = []
    @State private var selection: Int = 0
    
    
    @State private var isInFav: Bool = false
    @State private var curRating: Int = 0
    
    init(item:Item) {
            self.item = item
        }

    var body: some View {
        NavigationView{
            VStack(spacing: 0){
                itemAppBar()
                getItem()
            }.navigationBarHidden(true)
            .onAppear{
                dataService.isInFav(userId: authService.currentUser!, itemId: item.id)
                { value in
                    DispatchQueue.main.async {
                        self.isInFav = value
                    }
                }
                dataService.getRatings(itemId: item.id, userId: authService.currentUser!)
                { value in
                    DispatchQueue.main.async {
                        curRating = value
                    }
                }
            }
        }.navigationBarHidden(true)
    }
    
    func getItem() -> some View {
        return
        LinearGradient(gradient: Gradient(colors: [Color.white, Color(red: 255/255, green: 184/255, blue: 78/255)]),
                                           startPoint: .top,
                                           endPoint: .bottom)
        .edgesIgnoringSafeArea(.vertical).overlay(
        ScrollView {
            VStack{
                Spacer().frame(height: 20)
                if ((item.images) == nil){
                    VStack {
                            if let image = image {
                                Image(uiImage: image)
                                    .resizable()
                                    .aspectRatio(contentMode: .fill)
                                    .frame(width: UIScreen.main.bounds.width / 1.1, height: 250)
                                    .clipShape(RoundedRectangle(cornerRadius: 20))
                            } else {
                                Text("Loading...") .foregroundColor(.black).frame(width: UIScreen.main.bounds.width / 1.1, height: 250)
                            }
                        }
                        .onAppear {
                            downloadImageFromFirebase(path: item.img)
                        }
                }
                else{
                    VStack {
                        ZStack{
                            Color.white
                            TabView(selection: $selection){
                                ForEach(0..<7){ index in
                                    if index < images.count, let image = images[index] {
                                        Image(uiImage: image)
                                                                                  .resizable()
                                                                                  .aspectRatio(contentMode: .fill)
                                                                                  .frame(width: UIScreen.main.bounds.width / 1.1, height: 250)
                                                                                  .clipShape(RoundedRectangle(cornerRadius: 20))
                                    }else {
                                        Text("Loading...") .foregroundColor(.black).frame(width: UIScreen.main.bounds.width / 1.1, height: 250)
                                    }
                                    
                                }
                            }.tabViewStyle(PageTabViewStyle(indexDisplayMode: .automatic))
                                .indexViewStyle(PageIndexViewStyle(backgroundDisplayMode: .never))
                                .frame(width: UIScreen.main.bounds.width / 1.1, height: 250)
                                .clipShape(RoundedRectangle(cornerRadius: 20))
                            
                        }
                        
                    }
                        .onAppear {
                            downloadImagesFromFirebase(path: item.images!)
                        }
                }
                
                HStack {
                    Text(item.name)                  .font(.custom("Alata", size: 30))
                    Spacer()
                    
                    if isInFav {
                        Button(action: {
                            dataService.deleteFromFav(userId: authService.currentUser!, itemId: item.id)
                            isInFav = false
                        }) {
                            Image(systemName: "heart.fill")
                                .resizable()
                                .frame(width: 40, height: 40)
                                .foregroundColor(.black)
                        }
                    } else {
                        Button(action: {
                            dataService.addToFav(userId: authService.currentUser!, itemId: item.id)
                            isInFav = true
                        }) {
                            Image(systemName: "heart")
                                .resizable()
                                .frame(width: 40, height: 40)
                                .foregroundColor(.black)
                        }
                    }
                }
                .padding(.horizontal, 30)
                .padding(.vertical, 5)
                
                VStack(alignment: .leading) {
                    HStack {
                        Button(action: {dataService.saveRating(item: item, userId: authService.currentUser!, rating: 1)})
                        {if curRating > 0
                            {   Image(systemName: "star.fill").resizable()
                                            .frame(width: 40, height: 40)
                                            .foregroundColor(Color.yellow)}
                            else {
                                Image(systemName: "star").resizable()
                                            .frame(width: 40, height: 40)
                                            .foregroundColor(Color.yellow)
                            }
                        }
                        Button(action: {dataService.saveRating(item: item, userId: authService.currentUser!, rating: 2)
                                    curRating = 2
                        }) {if curRating > 1
                            {   Image(systemName: "star.fill").resizable()
                                            .frame(width: 40, height: 40)
                                            .foregroundColor(Color.yellow)}
                            else {
                                Image(systemName: "star").resizable()
                                            .frame(width: 40, height: 40)
                                            .foregroundColor(Color.yellow)
                            }
                        }
                        Button(action: {
                            dataService.saveRating(item: item, userId: authService.currentUser!, rating: 3)
                                    curRating = 3
                        }) {if curRating > 2
                            {   Image(systemName: "star.fill").resizable()
                                            .frame(width: 40, height: 40)
                                            .foregroundColor(Color.yellow)}
                            else {
                                Image(systemName: "star").resizable()
                                            .frame(width: 40, height: 40)
                                            .foregroundColor(Color.yellow)
                            }
                        }
                        Button(action: {
                            dataService.saveRating(item: item, userId: authService.currentUser!, rating: 4)
                                    curRating = 4
                        }) {if curRating > 3
                            {   Image(systemName: "star.fill").resizable()
                                            .frame(width: 40, height: 40)
                                            .foregroundColor(Color.yellow)}
                            else {
                                Image(systemName: "star").resizable()
                                            .frame(width: 40, height: 40)
                                            .foregroundColor(Color.yellow)
                            }
                        }
                        Button(action: {
                            dataService.saveRating(item: item, userId: authService.currentUser!, rating: 5)
                                    curRating = 5
                        }) {if curRating > 4
                            {   Image(systemName: "star.fill").resizable()
                                            .frame(width: 40, height: 40)
                                            .foregroundColor(Color.yellow)}
                            else {
                                Image(systemName: "star").resizable()
                                            .frame(width: 40, height: 40)
                                            .foregroundColor(Color.yellow)
                            }
                        }
                    }
                }
                
                HStack {
                    HStack {
                        Image(systemName: "clock") .foregroundColor(.black)
                        Text(item.time).font(.custom("Alata", size: 20)) .foregroundColor(.black)
                                
                    }.frame(width: 110)
                    Spacer()
                    HStack {
                        Image(systemName: "person") .foregroundColor(.black)
                        Text(item.diff).font(.custom("Alata", size: 20)) .foregroundColor(.black)
                    }.frame(width: 100)
                    Spacer()
                    HStack {
                        Image(systemName: "dollarsign.circle") .foregroundColor(.black)
                        Text("\(item.price)").font(.custom("Alata", size: 20)) .foregroundColor(.black)
                    }.frame(width: 60)
                
                }.padding(.horizontal, 20).padding(.vertical, 5)
                
                ZStack {
                    RoundedRectangle(cornerRadius: 20)
                        .fill(Color.white)
                        .frame(height: 365)
                        .padding(.horizontal,20)
                        .padding(.vertical, 0)
                        
                            Text(item.desk)
                                .font(.system(size: 24))
                                .padding(.horizontal,40)
                                .padding(.vertical, 20)
                }
            }
        }
        )
    }
    
    func downloadImageFromFirebase(path: String) {
           let storage = Storage.storage()
           let storageRef = storage.reference(withPath: "img/\(path)")

           storageRef.getData(maxSize: 1 * 1024 * 1024) { data, error in
               if let error = error {
                   print("Error downloading image: \(error.localizedDescription)")
               } else {
                   if let data = data {
                       if let uiImage = UIImage(data: data) {
                           image = uiImage
                       }
                   }
               }
           }
       }
    func downloadImagesFromFirebase(path: String) {
           let storage = Storage.storage()
        for i in 0...6{
           let storageRef = storage.reference(withPath: "\(path)/0\(i+1).jpg")

           storageRef.getData(maxSize: 1 * 1024 * 1024) { data, error in
               if let error = error {
                   print("Error downloading image: \(error.localizedDescription)")
               } else {
                   if let data = data {
                       if let uiImage = UIImage(data: data) {
                           images.append(uiImage)
                       }
                   }
               }
           }
            
        }
       }
    
    func itemAppBar() -> some View {
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
                    Text("Item")
                                   .font(.title)
                                   .foregroundColor(.white)
                                   .fontWeight(.bold)
                                   .padding(.top, 10)
                    Spacer()
                    
                    NavigationLink(destination: CommentListView(item:item)) {
                        Image(systemName: "message")
                                                .foregroundColor(.white)
                                                .font(.title)
                    }
                    Spacer().frame(width: 10)
                }
            }
    }
}
