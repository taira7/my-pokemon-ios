//
//  PokemonTypeColor.swift
//  MyPokemon
import SwiftUI

struct PokemonTypeColor{
    static func getTypeColor(_ type:String) -> Color{
        switch type {
        case "bug":
            return Color("bug")
        case "dark":
            return Color("dark")
        case"dragon":
            return Color("dragon")
        case "electric":
            return Color("electric")
        case "fairy":
            return Color("fairy")
        case"fighting":
            return Color("fighting")
        case "fire":
            return Color("fire")
        case "frying":
            return Color("frying")
        case "ghost":
            return Color("ghost")
        case "grass":
            return Color("grass")
        case "ground":
            return Color("ground")
        case "ice":
            return Color("ice")
        case "normal":
            return Color("normal")
        case "poison":
            return Color("poison")
        case "psychic":
            return Color("psychic")
        case "rock":
            return Color("rock")
        case "steel":
            return Color("steel")
        case "stellar":
            return Color("stellar")
        case "water":
            return Color("water")
        default:
            return Color("unknown")
        }
    }
}

