//
//  Model.swift
//  SwiftTalk
//
//  Created by Chris Eidhof on 27.06.19.
//  Copyright © 2019 Chris Eidhof. All rights reserved.
//

import Foundation
import SwiftUI
import TinyNetworking
import Model

extension CollectionView: Identifiable {}
extension EpisodeView: Identifiable {
    public var id: Int { number }
}

extension EpisodeView {
    var durationAndDate: String {
        "\(TimeInterval(media_duration).hoursAndMinutes) · \(released_at.pretty)"
    }
}

extension CollectionView {
    var episodeCountAndTotalDuration: String {
        "\(episodes_count) episodes ᐧ \(TimeInterval(total_duration).hoursAndMinutes)"
    }
}

let allCollections = Endpoint<[CollectionView]>(json: .get, url: URL(string: "https://talk.objc.io/collections.json")!)
let allEpisodes = Endpoint<[EpisodeView]>(json: .get, url: URL(string: "https://talk.objc.io/episodes.json")!)

let sampleCollections: [CollectionView] = sample(name: "collections")
let sampleEpisodes: [EpisodeView] = sample(name: "episodes")

import Combine

final class Store: BindableObject {
    let didChange: AnyPublisher<([CollectionView]?, [EpisodeView]?), Never>
    let sharedCollections = Resource(endpoint: allCollections)
    let sharedEpisodes = Resource(endpoint: allEpisodes)
    
    init() {
        didChange = sharedCollections.didChange.zip(sharedEpisodes.didChange).eraseToAnyPublisher()
    }
    
    var loaded: Bool {
        sharedCollections.value != nil && sharedEpisodes.value != nil
    }
    
    var collections: [CollectionView] { sharedCollections.value ?? [] }
    var episodes: [EpisodeView] { sharedEpisodes.value ?? [] }
}

let sharedStore = Store()

func sample<A: Codable>(name: String) -> A {
    let url = Bundle.main.url(forResource: name, withExtension: "json")!
    let data = try! Data(contentsOf: url)
    let decoder = JSONDecoder()
    decoder.dateDecodingStrategy = .secondsSince1970
    return try! decoder.decode(A.self, from: data)
}

