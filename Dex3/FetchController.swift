//
//  FetchController.swift
//  Dex3
//
//  Created by Krishnan Singaram on 01/02/25.
//

import Foundation
import CoreData

struct FetchController {

    enum NetworkError: Error {
        case badURL, badResponse, badData
    }

    private let baseURL = URL(string: "https://pokeapi.co/api/v2/pokemon/")!

    func fetchAllPokemons() async throws -> [PokemonModel]? {
        
        if(havePokemon()) {
            return nil
        }
        
        var pokemons: [PokemonModel] = []

        // Fetch Component
        var fetchComponent = URLComponents(
            url: baseURL, resolvingAgainstBaseURL: true)
        fetchComponent?.queryItems = [URLQueryItem(name: "limit", value: "10")]

        // Fetch URL
        guard let fetchURL = fetchComponent?.url else {
            throw NetworkError.badURL
        }

        // Fetch data from URL
        let (data, response) = try await URLSession.shared.data(from: fetchURL)

        // Check data and response
        guard let response = response as? HTTPURLResponse,
            response.statusCode == 200
        else {
            throw NetworkError.badResponse
        }

        // Get pokemon dictionary data
        guard
            let pokemonDictionary = try JSONSerialization.jsonObject(
                with: data
            ) as? [String: Any],
            let pokedex = pokemonDictionary["results"] as? [[String: String]]
        else {
            throw NetworkError.badData
        }

        // Iterate the pokedex
        for poke in pokedex {
            if let url = poke["url"] {
                pokemons.append(try await fetchPokemon(from: URL(string: url)!))
            }
        }

        return pokemons
    }

    private func fetchPokemon(from url: URL) async throws -> PokemonModel {
        let (data, response) = try await URLSession.shared.data(from: url)

        guard
            let response = response as? HTTPURLResponse,
            response.statusCode == 200
        else {
            throw NetworkError.badResponse
        }

        let pokemon = try JSONDecoder().decode(PokemonModel.self, from: data)
        print("Fetched: \(pokemon.id): \(pokemon.name)")
        return pokemon
    }
    
    private func havePokemon() -> Bool {
        let context = PersistenceController.shared.container.newBackgroundContext()
        let fetchRequest: NSFetchRequest<Pokemon> = Pokemon.fetchRequest()
        fetchRequest.predicate = NSPredicate(format: "id IN %@", [1, 10])
        
        do {
            let checkPokemon = try context.fetch(fetchRequest)
            if checkPokemon.count == 2 {
                return true
            }
        } catch {
            print("CoreData Fetch Error: \(error)")
            return false
        }
        
        return false
    }
}
