//
//  StoreDemoExperiment.swift
//  ComposableCacheStoreExample
//
//  Created by 0x on 5/14/22.
//

import CacheStore
import SwiftUI

// MARK: - Experiment

struct StoreDemoExperiment: Experiment {
    var id: String { ExperimentIdentifier.storeDemo.rawValue }
    var title: String { "StoreDemo" }
    
    var screen: AnyView {
        AnyView(StoreDemoExperimentScreen())
    }
}

// MARK: - Screen

struct StoreDemoExperimentScreen: View {
    enum StateKey {
        case count
    }
    
    enum Action {
        case increment, decrement
    }
    
    static let actionHandler: StoreActionHandler<StateKey, Action, Void> = StoreActionHandler { store, action, _ in
        switch action {
        case .increment: store.update(.count, as: Int.self) { $0? += 1 }
        case .decrement: store.update(.count, as: Int.self) { $0? -= 1 }
        }
    }
    
    @ObservedObject var store: Store<StateKey, Action, Void> = Store(
        initialValues: [
            .count: 0
        ],
        actionHandler: StoreDemoExperimentScreen.actionHandler,
        dependency: ()
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
                    action: { store.handle(action: .decrement) },
                    label: {
                        Image(systemName: "minus.circle")
                            .font(.title)
                    }
                )
                .disabled(count <= 0)
                
                Button(
                    action: { store.handle(action: .increment) },
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

struct StoreDemoExperimentPreviews: PreviewProvider {
    static var previews: some View {
        StoreDemoExperiment().screen
    }
}
