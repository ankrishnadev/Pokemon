//
//  FetchController.swift
//  Dex3
//
//  Created by Krishnan Singaram on 01/02/25.
//

import Foundation

struct FetchController {

    enum NetworkError: Error {
        case badURL, badResponse, badData
    }

    private let baseURL = URL(string: "https://pokeapi.co/api/v2/pokemon/")!

    func fetchAllPokemons() async throws -> [PokemonModel] {
        var pokemons: [PokemonModel] = []

        // Fetch Component
        var fetchComponent = URLComponents(
            url: baseURL, resolvingAgainstBaseURL: true)
        fetchComponent?.queryItems = [URLQueryItem(name: "limit", value: "386")]

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
            throw NetworkError.badURL
        }

        let pokemon = try JSONDecoder().decode(PokemonModel.self, from: data)
        print("Fetched: \(pokemon)")
        return pokemon
    }
}
