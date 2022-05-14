//
//  Experiment.swift
//  ComposableCacheStoreExample
//
//  Created by 0x on 5/12/22.
//

import SwiftUI

protocol Experiment {
    var id: String { get }
    var title: String { get }
    
    var screen: AnyView { get }
}

enum ExperimentIdentifier: String, CaseIterable {
    case counter
    case sharedState
    case favoritePosts
    case basicMVVM
}

extension ExperimentIdentifier {
    var experiment: Experiment {
        switch self {
        case .counter: return CounterExperiment()
        case .sharedState: return SharedStateExperiment()
        case .favoritePosts: return FavoritePostsExperiment()
        case .basicMVVM: return BasicMVVMExperiment()
        }
    }
}
