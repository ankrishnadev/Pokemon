//
//  PokemonDetailView.swift
//  Dex3
//
//  Created by Krishnan Singaram on 02/02/25.
//

import CoreData
import SwiftUI

struct PokemonDetailView: View {
    @Environment(\.managedObjectContext) private var viewContext
    @EnvironmentObject var pokemon: Pokemon
    @State var showShinny = false

    var body: some View {
        ScrollView {
            ZStack {
                Image(pokemon.background)
                    .resizable()
                    .scaledToFit()

                AsyncImage(
                    url: showShinny ? pokemon.shinyURL : pokemon.spriteURL
                ) { image in
                    image.resizable()
                        .scaledToFit()
                        .padding(.top, 50)
                        .shadow(color: .black, radius: 10)
                } placeholder: {
                    ProgressView()
                }
            }

            HStack {
                ForEach(pokemon.types!, id: \.self) { type in
                    Text(type.capitalized)
                        .font(.title2)
                        .padding([.leading, .trailing], 30)
                        .padding([.top, .bottom], 10)
                        .background(Color(type.capitalized))
                        .clipShape(Capsule())
                }

                Spacer()

                Button {
                    withAnimation {
                        pokemon.favorite.toggle()
                    }
                    
                    do {
                        try viewContext.save()
                    } catch {
                        let nsError = error as NSError
                        fatalError("Unresolved error \(nsError), \(nsError.userInfo)")
                    }
                    
                } label: {
                    if pokemon.favorite {
                        Image(systemName: "star.fill")
                    } else {
                        Image(systemName: "star")
                    }
                }
                .font(.title2)
                .foregroundStyle(Color(pokemon.types![0].capitalized))
            }
            .padding()

            VStack(alignment: .leading) {
                Text("Stats").font(.title2)
                    .padding(.leading, 20)
                    .padding(.bottom, -10)

                Stats().environmentObject(pokemon).padding(.leading, 5)
            }
        }
        .navigationTitle(pokemon.name!.capitalized)
        .toolbar {
            ToolbarItem(placement: .navigationBarTrailing) {
                Button {
                    showShinny.toggle()
                } label: {
                    if showShinny {
                        Image(systemName: "wand.and.stars")
                            .foregroundStyle(
                                Color(pokemon.types![0].capitalized))
                    } else {
                        Image(systemName: "wand.and.sparkles.inverse")
                    }
                }
            }
        }
    }
}

struct PokemonDetailView_Previews: PreviewProvider {
    static var previews: some View {
        PokemonDetailView().environmentObject(SamplePokemon.samplePokemon)
    }
}
