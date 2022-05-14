//
//  BasicMVVMExperiment.swift
//  ComposableCacheStoreExample
//
//  Created by 0x on 5/12/22.
//

import CacheStore
import SwiftUI

// MARK: - Experiment

struct BasicMVVMExperiment: Experiment {
    var id: String { ExperimentIdentifier.basicMVVM.rawValue }
    var title: String { "Basic MVVM" }
    
    var screen: AnyView {
        AnyView(
            BasicMVVMExperimentScreen(
                viewModel: BasicViewModel()
            )
        )
    }
}

/* MVVM
 - Model
 - View
 - ViewModel
 */

// MARK: - Models

struct BasicModel {
    var title: String
    var count: Int
}


// MARK: - ViewModel

class BasicViewModel: ObservableObject {
    enum CacheKey {
        case state // BasicModel
    }

    private var store: CacheStore<CacheKey> = CacheStore(
        initialValues: [
            .state: BasicModel(title: "Init", count: 0)
        ]
    )
    
    var state: BasicModel {
        store.resolve(.state, as: BasicModel.self)
    }
    
    var title: String { state.title }
    var count: Int { state.count }
    var isDecrementDisabled: Bool { count <= 0 }
    
    func decrement() {
        objectWillChange.send()
        var state: BasicModel = store.resolve(.state)
        
        state.count -= 1
        
        store.set(value: state, forKey: .state)
    }
    
    func increment() {
        objectWillChange.send()
        var state: BasicModel = store.resolve(.state)
        
        state.count += 1
        
        store.set(value: state, forKey: .state)
    }
}

// MARK: - View

struct BasicMVVMExperimentScreen: View {
    @ObservedObject var viewModel: BasicViewModel
    
    var body: some View {
        VStack {
            Text("\(viewModel.title)")
                .font(.largeTitle)
                .fontWeight(.heavy)
            Text("\(viewModel.count)")
                .font(.largeTitle)
                .fontWeight(.heavy)
            
            HStack {
                Button(
                    action: viewModel.decrement,
                    label: {
                        Image(systemName: "minus.circle")
                            .font(.title)
                    }
                )
                .disabled(viewModel.isDecrementDisabled)
                
                Button(
                    action: viewModel.increment,
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

struct BasicMVVMExperimentPreviews: PreviewProvider {
    static var previews: some View {
        BasicMVVMExperiment().screen
    }
}
