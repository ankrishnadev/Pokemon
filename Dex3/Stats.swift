//
//  Stats.swift
//  Dex3
//
//  Created by Krishnan Singaram on 09/02/25.
//

import Charts
import SwiftUI

struct Stats: View {
    @EnvironmentObject var pokemon: Pokemon

    var body: some View {
        Chart(pokemon.stats) { stat in
            BarMark(
                x: .value("Value", stat.value),
                y: .value("Stat", stat.label)
            )
            .annotation(position: .trailing) {
                Text("\(stat.value)").font(.caption)
                    .foregroundStyle(.secondary)
            }
        }
        .frame(height: 200)
        .foregroundStyle(Color(pokemon.types![0].capitalized))
        .padding()
    }
}

struct StatPreviews: PreviewProvider {
    static var previews: some View {
        Stats().environmentObject(SamplePokemon.samplePokemon)
    }
}
