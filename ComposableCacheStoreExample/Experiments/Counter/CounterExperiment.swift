//
//  CounterExperiment.swift
//  ComposableCacheStoreExample
//
//  Created by 0x on 5/11/22.
//

import CacheStore
import SwiftUI

// MARK: - Experiment

struct CounterExperiment: Experiment {
    var id: String { ExperimentIdentifier.counter.rawValue }
    var title: String { "Counter" }
    
    var screen: AnyView {
        AnyView(CounterExperimentScreen())
    }
}

// MARK: - Screen

struct CounterExperimentScreen: View {
    enum CacheKey {
        case count
    }
    
    @ObservedObject var store: CacheStore<CacheKey> = CacheStore(
        initialValues: [.count: 0]
    )
    
    private var count: Int {
        store.resolve(.count)
    }
    
    var body: some View {
        VStack {
            Text("\(count)")
                .font(.largeTitle)
                .fontWeight(.heavy)
            
            HStack {
                Button(
                    action: {
                        store.set(value: count - 1, forKey: .count)
                    },
                    label: {
                        Image(systemName: "minus.circle")
                            .font(.title)
                    }
                )
                .disabled(count <= 0)
                
                Button(
                    action: { store.set(value: count + 1, forKey: .count) },
                    label: {
                        Image(systemName: "plus.circle")
                            .font(.title)
                    }
                )
            }
        }
    }
}

// MARK: - Screen Preview

struct CounterExperimentPreviews: PreviewProvider {
    static var previews: some View {
        CounterExperiment().screen
    }
}
