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

    @FetchRequest(
        sortDescriptors: [
            NSSortDescriptor(keyPath: \Pokemon.id, ascending: true)
        ],
        predicate: NSPredicate(format: "favorite == %d", true),
        animation: .default
    )
    private var favorite: FetchedResults<Pokemon>
    
    @FetchRequest<Pokemon>(sortDescriptors: []) private var all

    @State private var filterByFavorite = false

    @StateObject var viewModel = PokemonViewModel(controller: FetchController())

    var body: some View {
//        switch viewModel.state {
//        case .success:
            NavigationStack {
                List(filterByFavorite ? favorite : pokedex) { pokemon in
                    NavigationLink(value: pokemon) {
                        AsyncImage(url: pokemon.spriteURL) {
                            image in
                            image
                                .resizable()
                                .scaledToFit()
                        } placeholder: {
                            ProgressView()
                        }
                        .frame(width: 100, height: 100)

                        VStack(alignment: .leading) {
                            HStack {
                                Text(pokemon.name!.capitalized)
                                    .font(.title2)
                                    .bold()

                                if pokemon.favorite {
                                    Image(systemName: "star.fill")
                                        .foregroundStyle(.yellow)
                                }
                            }

                            HStack {
                                ForEach(pokemon.types!, id: \.self) { type in
                                    Text(type.capitalized)
                                        .font(.subheadline)
                                        .padding([.leading, .trailing], 12)
                                        .background(Color(type.capitalized))
                                        .clipShape(Capsule())
                                        
                                }
                            }
                        }
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
                        Button {
                            withAnimation {
                                filterByFavorite.toggle()
                            }
                        } label: {
                            Label(
                                "Favorites",
                                systemImage: filterByFavorite
                                    ? "star.fill" : "star"
                            )
                        }
                    }
                }
            }
//        default:
//            ProgressView()
//        }
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView().environment(
            \.managedObjectContext,
            PersistenceController.preview.container.viewContext)
    }
}
