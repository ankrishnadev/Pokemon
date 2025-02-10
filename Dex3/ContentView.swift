//
//  ContentView.swift
//  Dex3
//
//  Created by Krishnan Singaram on 25/01/25.
//

import CoreData
import SwiftUI

struct ContentView: View {
    @Environment(\.managedObjectContext) private var viewContext

    @FetchRequest(
        sortDescriptors: [
            NSSortDescriptor(keyPath: \Pokemon.id, ascending: true)
        ],
        animation: .default
    )
    private var pokedex: FetchedResults<Pokemon>

    @StateObject var viewModel = PokemonViewModel(controller: FetchController())

    var body: some View {
        switch viewModel.state {
        case .success:
            NavigationStack {
                List(pokedex) { pokemon in
                    NavigationLink(value: pokemon) {
                        AsyncImage(url: pokemon.sprite) {
                            image in
                            image
                                .resizable()
                                .scaledToFit()
                        } placeholder: {
                            ProgressView()
                        }
                        .frame(width: 100, height: 100)

                        Text(pokemon.name!.capitalized)
                    }
                }
                .navigationTitle("Pokédex")
                .navigationDestination(
                    for: Pokemon.self,
                    destination: { pokemon in
                        PokemonDetailView().environmentObject(pokemon)
                    }
                )
                .toolbar {
                    ToolbarItem(placement: .navigationBarTrailing) {
                        EditButton()
                    }
                }
            }
        default:
            ProgressView()
        }
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView().environment(
            \.managedObjectContext,
            PersistenceController.preview.container.viewContext)
    }
}
