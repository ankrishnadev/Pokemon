//
//  PokemonViewModel.swift
//  Dex3
//
//  Created by Krishnan Singaram on 01/02/25.
//

import Foundation

@MainActor
class PokemonViewModel: ObservableObject {
    enum State {
        case notStarted
        case fetching
        case success
        case failed(error: Error)
    }

    @Published var state: State = .notStarted

    private let controller: FetchController

    init(controller: FetchController) {
        self.controller = controller
        
        Task {
            await getPokemon()
        }
    }

    private func getPokemon() async {
        state = .fetching

        do {
            guard var pokedex = try await controller.fetchAllPokemons() else {
                print("Pokemon data fetched, We good!")
                state = .success
                return
            }
            
            pokedex.sort { $0.id < $1.id }

            for pokemon in pokedex {
                let newPokemon = Pokemon(
                    context: PersistenceController.shared.container
                        .viewContext)
                
                newPokemon.id = Int16(pokemon.id)
                newPokemon.name = pokemon.name
                newPokemon.types = pokemon.types
                newPokemon.organizedTypes()
                newPokemon.hp = Int16(pokemon.hp)
                newPokemon.attack = Int16(pokemon.attack)
                newPokemon.defense = Int16(pokemon.defense)
                newPokemon.specialAttack = Int16(pokemon.specialAttack)
                newPokemon.specialDefense = Int16(pokemon.specialDefense)
                newPokemon.speed = Int16(pokemon.speed)
                newPokemon.sprite = pokemon.sprite
                newPokemon.shiny = pokemon.shiny
                newPokemon.favorite = false
                
                try PersistenceController.shared.container.viewContext.save()
                
            }
            
            state = .success
        } catch {
            state = .failed(error: error)
        }
    }
}
