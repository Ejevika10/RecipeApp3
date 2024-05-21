//
//  ItemInList.swift
//  lab3
//
//  Created by Viktoriya on 26.04.24.
//

import SwiftUI
import FirebaseStorage

struct ItemInList: View {
    let item: Item
    @State private var image: UIImage? = nil
    
    var body: some View {
        Button(action:{})
        {
            VStack{
                VStack {
                        if let image = image {
                            Image(uiImage: image)
                                .resizable()
                                .aspectRatio(contentMode: .fill)
                                .frame(width: UIScreen.main.bounds.width / 1.25, height: 200)
                                .clipShape(RoundedRectangle(cornerRadius: 20))
                        } else {
                            Text("Loading...") .foregroundColor(.black)
                        }
                    }
                    .onAppear {
                        downloadImageFromFirebase(path: item.img)
                    }
            
            HStack {
                            Text(item.name)
                                .font(.custom("Alata", size: 25)) .foregroundColor(.black)
                            
                            Spacer()
                            
                            HStack {
                                Text(String(format: "%.1f", item.avgRating!))
                                    .font(.custom("Alata", size: 25))
                                    .fontWeight(.bold) .foregroundColor(.black)
                                Image(systemName: "star")
                                    .foregroundColor(.yellow)
                            }
            }.padding(.horizontal, 20).padding(.vertical, 5)
            
                        
            HStack {
                HStack {
                                Image(systemName: "clock") .foregroundColor(.black)
                                Text(item.time)
                                    .font(.custom("Alata", size: 17)) .foregroundColor(.black)
                            }
                            .frame(width: 100)
                            
                            
                Spacer()
                HStack {
                                Image(systemName: "person") .foregroundColor(.black)
                                Text(item.diff)
                                    .font(.custom("Alata", size: 17)) .foregroundColor(.black)
                            }
                            .frame(width: 100)
                            
                            Spacer()
                            
                            
                HStack {
                                Image(systemName: "dollarsign.circle") .foregroundColor(.black)
                                Text("\(item.price)")
                                    .font(.custom("Alata", size: 17)) .foregroundColor(.black)
                }.frame(width: 50)
            
            }.padding(.horizontal, 20).padding(.vertical, 5)
            
        
            }.cornerRadius(20)
            .padding(.vertical, 20)
        }
        .background(
                    NavigationLink(destination: ItemView(item: item)) {
                        EmptyView()
                    }
                    .buttonStyle(PlainButtonStyle())
                )
                .navigationBarBackButtonHidden(true)
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
}
