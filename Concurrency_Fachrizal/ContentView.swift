//
//  ContentView.swift
//  Concurrency_Fachrizal
//
//  Created by Randy Senjaya on 07/08/23.
//

import SwiftUI

struct WaifuDetails: Codable{
    let name:String
    let anime:String
    let image:String
}

enum WUError: Error {
    case invalidURL
    case invalidResponse
    case invalidData
}



struct ContentView: View {
    
    
    @State private var waifu :[WaifuDetails] = []
    
    private var searchResult: [WaifuDetails]{
        
        if searchText.isEmpty{
            return waifu
        } else{
            return waifu.filter { index in
                index.name.lowercased().contains(searchText.lowercased()) ||
                index.anime.lowercased().contains(searchText.lowercased())
            }
        }
    }
    
    @State private var searchText:String = ""
    
    
    var body: some View {
        
        NavigationStack{
            List(searchResult, id: \.name) {waifu in
                HStack(spacing: 20){
                    AsyncImage(url: URL(string: "\(waifu.image)")){ phase in
                        VStack {
                            if let image = phase.image {
                                image
                                    .resizable()
                                    .frame(width: 80, height: 80)
                                    .clipShape(RoundedRectangle(cornerRadius: 100))
                                    .scaledToFit()
                                
                            } else if phase.error != nil {
                                Color.red
                                    .frame(width: 80, height: 80)
                                    .clipShape(RoundedRectangle(cornerRadius: 100))
                                
                            } else {
                                AsyncImage(url: URL(string: "https://res.cloudinary.com/moyadev/image/upload/v1691380966/Moyadev/default_afp8ju.png"))
                                    .scaledToFit()
                                    .frame(width: 80, height: 80)
                                    .clipShape(RoundedRectangle(cornerRadius: 100))
                            }
                        }
                    }
                    
                    VStack(alignment: .leading){
                        Text(waifu.name)
                            .fontWeight(.bold)
                            .font(.title3)
                        
                        Text(waifu.anime)
                            .font(.subheadline)
                    }
                }
                .listRowSeparator(.visible)
            }
            .searchable(text: $searchText)
            .listStyle(.plain)
            .navigationTitle("WAIFU LIST")
            .task {
                do {
                    waifu = try await getWaifu()
                } catch WUError.invalidURL {
                    print("Invalid URL")
                } catch WUError.invalidData {
                    print("Invalid data")
                } catch WUError.invalidResponse {
                    print("Invalid response")
                } catch {
                    print("Unexpected error")
                }
            }
        }
    }
    
    func getWaifu() async throws -> [WaifuDetails] {
        let endpoint = "https://waifu-generator.vercel.app/api/v1"
        
        guard let url = URL(string: endpoint) else {
            throw WUError.invalidURL
        }
        
        let (data, response) = try await URLSession.shared.data(from: url)
        
        guard let response = response as? HTTPURLResponse, response.statusCode == 200 else {
            throw WUError.invalidResponse
        }
        
        do {
            let decoder = JSONDecoder()
            decoder.keyDecodingStrategy = .convertFromSnakeCase
            return try decoder.decode([WaifuDetails].self, from: data)
            
        } catch {
            throw WUError.invalidData
        }
    }
    
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
