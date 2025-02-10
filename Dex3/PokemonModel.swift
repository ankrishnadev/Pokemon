//
//  PokemonModel.swift
//  Dex3
//
//  Created by Krishnan Singaram on 25/01/25.
//

import Foundation

class PokemonModel: Codable {
    let id: Int
    let name: String
    let types: [String]
    var hp: Int = 0
    var attack: Int = 0
    var defense: Int = 0
    var specialAttack: Int = 0
    var specialDefense: Int = 0
    var speed: Int = 0
    let sprite: URL
    let shiny: URL

    enum PokemonKeys: String, CodingKey {
        case id
        case name
        case types
        case stats
        case sprites

        enum TypeDictionaryKeys: String, CodingKey {
            case type

            enum TypeKeys: String, CodingKey {
                case name
            }
        }

        enum StatsDictionaryKeys: String, CodingKey {
            case value = "base_stat"
            case stat

            enum StatKeys: String, CodingKey {
                case name
            }
        }

        enum SpritesKeys: String, CodingKey {
            case frontDefaulst = "front_default"
            case frontShiny = "front_shiny"
        }
    }

    required init(from decoder: Decoder) throws {
        let containter = try decoder.container(keyedBy: PokemonKeys.self)

        id = try containter.decode(Int.self, forKey: .id)
        name = try containter.decode(String.self, forKey: .name)

        var decodedTypes: [String] = []
        var typesContainer = try containter.nestedUnkeyedContainer(
            forKey: .types)

        while !typesContainer.isAtEnd {
            let typeDictionaryContainer = try typesContainer.nestedContainer(
                keyedBy: PokemonKeys.TypeDictionaryKeys.self)
            let typeContainer = try typeDictionaryContainer.nestedContainer(
                keyedBy: PokemonKeys.TypeDictionaryKeys.TypeKeys.self,
                forKey: .type
            )

            let type = try typeContainer.decode(String.self, forKey: .name)
            decodedTypes.append(type)
        }
        types = decodedTypes

        var statContainer = try containter.nestedUnkeyedContainer(
            forKey: .stats)
        while !statContainer.isAtEnd {
            let statDictionaryContainer = try statContainer.nestedContainer(
                keyedBy: PokemonKeys.StatsDictionaryKeys.self)
            let statContainer = try statDictionaryContainer.nestedContainer(
                keyedBy: PokemonKeys.StatsDictionaryKeys.StatKeys.self,
                forKey: .stat
            )
        
            switch try statContainer.decode(String.self, forKey: .name) {
            case "hp":
                hp = try statDictionaryContainer.decode(
                    Int.self, forKey: .value)
            case "attack":
                attack = try statDictionaryContainer.decode(
                    Int.self, forKey: .value)
            case "defense":
                defense = try statDictionaryContainer.decode(
                    Int.self, forKey: .value)
            case "special-attack":
                specialAttack = try statDictionaryContainer.decode(
                    Int.self, forKey: .value)
            case "special-defense":
                    specialDefense = try statDictionaryContainer.decode(
                    Int.self, forKey: .value)
            case "speed":
                speed = try statDictionaryContainer.decode(
                    Int.self, forKey: .value)
            default:
                print("no result")
            }
        }
        
        let spriteContainer = try containter.nestedContainer(
            keyedBy: PokemonKeys.SpritesKeys.self,
            forKey: .sprites
        )

        sprite = try spriteContainer.decode(URL.self, forKey: .frontDefaulst)
        shiny = try spriteContainer.decode(URL.self, forKey: .frontShiny)
    }

}
