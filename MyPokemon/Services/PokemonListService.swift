//
//  PokemonListService.swift
//  MyPokemon

import Foundation

struct PokemonSummary:Decodable {
    let name: String
    let url: String
}

struct PokemonListResponse:Decodable {
    let count: Int
    var next: String?
    var previous: String?
    var results: [PokemonSummary]
}

struct PokemonType: Decodable {
    let name: String
}

struct PokemonTypeEntry: Decodable {
    let type: PokemonType
}

struct PokemonSprite: Decodable {
    let front_default: URL?
    let back_default: URL?
}


struct PokemonDetail: Decodable {
    let id: Int
    let name: String
    let height: Double
    let weight: Double
    let sprites: PokemonSprite
    let types: [PokemonTypeEntry]
}

@MainActor
 final class PokemonListService:ObservableObject {
    
     @Published var limit = 100
    
     @Published var pokemonResponse: PokemonListResponse? = nil
    
     @Published var isLoading: Bool = false
    
     func fetchPokemonListResponse(offset:Int) async -> PokemonListResponse? {
        let baseURL = "https://pokeapi.co/api/v2/pokemon?offset=\(offset)&limit=\(limit)"
        
        guard let url = URL(string: baseURL) else {
            print("URL生成エラー")
            return nil
        }
        
        do{
            let (data, _ ) = try await URLSession.shared.data(from: url)
            
            let decoder = JSONDecoder()
            let results = try decoder.decode(PokemonListResponse.self, from: data)
            
            return results
            
        }catch{
            print("error: \(error)")
            return nil
        }
    }
    
    func fetchPokemonDetail(urlString: String) async -> PokemonDetail? {
        
        guard let url = URL(string: urlString) else {
            print("URL生成エラー")
            return nil
        }
        
        do{
            let (data, _) = try await URLSession.shared.data(from: url)
            let decoder = JSONDecoder()
            let result = try decoder.decode(PokemonDetail.self, from: data)
            
            return result
            
        }catch{
            print("error: \(error)")
            return nil
        }
    }
    
     func fetchAllPokemonDetails(offset:Int) async -> [PokemonDetail]{
        var pokemonSummaries: [PokemonSummary] = []
        
        await MainActor.run{
            self.isLoading = true
        }
        
         pokemonResponse = await fetchPokemonListResponse(offset: offset)
        guard let pokemonResponse = pokemonResponse else {
            print("ポケモンリスト取得エラー")
            await MainActor.run{
                self.isLoading = false
            }
            return []
        }
        
        pokemonSummaries = pokemonResponse.results
        
        //ソートのためにidをつける
          var indexedDetails: [(Int, PokemonDetail)] = []

          await withTaskGroup(of: (Int, PokemonDetail)?.self) { group in
              for summary in pokemonSummaries {
                  group.addTask {
                      if let detail = await self.fetchPokemonDetail(urlString: summary.url) {
                          return (detail.id, detail)
                      }else{
                          return nil
                      }
                  }
              }

              for await result in group {
                  if let (id, detail) = result {
                      indexedDetails.append((id, detail))
                  }
              }
          }
        
        indexedDetails.sort(by: { (first, second) in
            return first.0 < second.0
        })
        
        let sortedDetails: [PokemonDetail] = indexedDetails.map(){ detail in
            return detail.1
        }

        // 一括でUI更新（MainActorで）
        await MainActor.run {
            self.isLoading = false
        }
         
         return sortedDetails
    }
     
    //お気に入りのポケモンのデータを取得
     func fetchFavoritePokemons (pokemonIds: [Int]) async -> [PokemonDetail] {
             var indexedDetails: [(Int, PokemonDetail)] = [] //ソートのための配列
             
             await withTaskGroup(of: (Int,PokemonDetail)?.self){ group in
                 for id in pokemonIds{
                     let url = "https://pokeapi.co/api/v2/pokemon/\(id)/"
                     group.addTask {
                         if let pokemonDetail = await self.fetchPokemonDetail(urlString: url){
                             return (pokemonDetail.id,pokemonDetail)
                         }else{
                             return nil
                         }
                     }
                 }
                 
                 for await result in group {
                     if let (id, detail) = result {
                         indexedDetails.append((id, detail))
                     }
                 }
                 
             }
         
             indexedDetails.sort(by: { (first, second) in
                 return first.0 < second.0
             })
             
             let sortedDetails: [PokemonDetail] = indexedDetails.map(){ detail in
                 return detail.1
             }
         
         return sortedDetails
     }
}

