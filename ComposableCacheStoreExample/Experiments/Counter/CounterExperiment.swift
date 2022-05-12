//
//  CounterExperiment.swift
//  ComposableCacheStoreExample
//
//  Created by 0x on 5/11/22.
//

import CacheStore
import SwiftUI

struct CounterExperiment: Experiment {
    var id: String { ExperimentIdentifier.counter.rawValue }
    var title: String { "Counter" }
    
    var screen: AnyView {
        AnyView(CounterExperimentScreen())
    }
}

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

struct CounterExperimentPreviews: PreviewProvider {
    static var previews: some View {
        CounterExperiment().screen
    }
}
