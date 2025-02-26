//
//  PokemonViewModel.swift
//  Dex3
//
//  Created by Krishnan Singaram on 01/02/25.
//

import Foundation
import SwiftUI

@MainActor
class PokemonViewModel: ObservableObject {
    enum State {
        case notStarted
        case fetching
        case success
        case failed(error: Error)
    }

    @Published var state: State = .notStarted
    
    @FetchRequest<Pokemon>(sortDescriptors: []) private var all

    private let controller: FetchController
    private let allPokemons: [Pokemon] = []
    
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
                newPokemon.spriteURL = pokemon.sprite
                newPokemon.shinyURL = pokemon.shiny
                newPokemon.favorite = false
                
                try PersistenceController.shared.container.viewContext.save()
                
            }
            
            state = .success
        } catch {
            state = .failed(error: error)
        }
        
        storeSprite()
    }
    
    private func storeSprite() {
        Task {
            do {
                for pokemon in all {
                    pokemon.sprite = try await URLSession.shared
                        .data(from: pokemon.spriteURL!).0
                    pokemon.shiny = try await URLSession.shared
                        .data(from: pokemon.shinyURL!).0
                }
                
                try PersistenceController.shared.container.viewContext.save()
                
            } catch {
                print(error)
            }
        }
    }
}
