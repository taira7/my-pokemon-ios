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
class PokemonListService:ObservableObject {
    
    init() {
        Task {
            await fetchAllPokemonDetails()
        }
    }
    
    @Published var offset = 0
    @Published var limit = 100
    
    @Published var pokemonResponse: PokemonListResponse? = nil
    
    var pokemonSummaries: [PokemonSummary] = []
    @Published var pokemonDetails:[PokemonDetail] = []
    
    @Published var isLoading: Bool = false
    
//    func getAllPokemonList() -> Void {
//        let baseURL = "https://pokeapi.co/api/v2/pokemon?offset=\(offset)&limit=\(limit)"
//        
//        URLSession.shared.dataTask(with: URL(string: baseURL)!) { (data, response, error) in
//            
//            if let error = error {
//                print("APIリクエストエラー: \(error.localizedDescription)")
//                return
//            }
//            
//            guard let data = data else { return }
//            let decoder: JSONDecoder = JSONDecoder()
//            do {
//                let resultData = try decoder.decode(PokemonAll.self, from: data)
//                DispatchQueue.main.async {
//                    self.pokemonData = resultData.results
//                    print("API結果",self.pokemonData)
//                }
//            } catch {
//                print("json convert failed in JSONDecoder. " + error.localizedDescription)
//            }
//        }.resume()
//
//    }
    
    func fetchPokemonListResponse() async -> PokemonListResponse? {
        let baseURL = "https://pokeapi.co/api/v2/pokemon?offset=\(offset)&limit=\(limit)"
        
        guard let url = URL(string: baseURL) else {
            print("URL生成エラー")
            return nil
        }
        
        do{
            let (data, _ ) = try await URLSession.shared.data(from: url)
//            print("data",data)
            
//            if let httpResponse = URLResponse as? HTTPURLResponse {
//                print("status code", httpResponse.statusCode)
//            } else {
//                print("not an HTTP response")
//            }
            
            let decoder = JSONDecoder()
            let results = try decoder.decode(PokemonListResponse.self, from: data)
            
//            print("API結果",results)
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
//            print("result: \(result)")
            
            return result
            
        }catch{
            print("error: \(error)")
            return nil
        }
    }
    
    func fetchAllPokemonDetails() async -> Void{
        await MainActor.run{
            self.isLoading = true
            self.pokemonDetails = []
        }
        
        pokemonResponse = await fetchPokemonListResponse()
//        print("pokemonResponse:",pokemonResponse ?? "nil")
        guard let pokemonResponse = pokemonResponse else {
            print("ポケモンリスト取得エラー")
            self.isLoading = false
            return
        }
        
        pokemonSummaries = pokemonResponse.results
        
        //ソートのためにidをつける
          var indexedDetails: [(Int, PokemonDetail)] = []

          await withTaskGroup(of: (Int, PokemonDetail)?.self) { group in
              for summary in pokemonSummaries {
                  group.addTask {
                      if let detail = await self.fetchPokemonDetail(urlString: summary.url) {
                          return (detail.id, detail)
                      } else {
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
            self.pokemonDetails = sortedDetails
            self.isLoading = false
        }
    }
}

