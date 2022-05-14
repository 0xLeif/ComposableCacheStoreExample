//
//  SharedStateExperiment.swift
//  ComposableCacheStoreExample
//
//  Created by 0x on 5/11/22.
//

import c
import CacheStore
import SwiftUI

// MARK: - Experiment

struct SharedStateExperiment: Experiment {
    enum ColorType: CaseIterable {
        case red
        case green
        case blue
        
        var color: Color {
            switch self {
            case .red:
                return .red
            case .green:
                return .green
            case .blue:
                return .blue
            }
        }
    }
    
    var id: String { ExperimentIdentifier.sharedState.rawValue }
    var title: String { "Shared State" }
    
    var screen: AnyView {
        AnyView(SharedStateExperimentScreen())
    }
}

// MARK: - Screen

struct SharedStateExperimentScreen: View {
    typealias ColorType = SharedStateExperiment.ColorType
    
    enum CacheKey: CaseIterable {
        case count // Int
        case color // ColorType
        case contentArray // [ColorType]
    }
    
    @ObservedObject var store: CacheStore<CacheKey> = CacheStore(
        initialValues: [
            .count: 0,
            .color: ColorType.red,
            .contentArray: []
        ]
    )
    
    private var count: Int {
        store.resolve(.count)
    }
    
    var body: some View {
        Form {
            SharedStateListView(
                store: store.scope(
                    keyTransformation: c.transformer(
                        from: { sharedStateCacheKey in
                            switch sharedStateCacheKey {
                            case .contentArray: return .contentArray
                            default: return nil
                            }
                        },
                        to: { sharedStateListCacheKey in
                            switch sharedStateListCacheKey {
                            case .contentArray: return .contentArray
                            default: return nil
                            }
                        }
                    )
                )
            )
        }
        .onAppear {
            store.set(
                value: [ColorType](
                    repeating: store.resolve(.color, as: ColorType.self),
                    count: store.resolve(.count)
                ),
                forKey: .contentArray
            )
        }
        .toolbar {
            NavigationLink(
                destination: {
                    SharedStateEditView(
                        store: store.scope(
                            keyTransformation: c.transformer(
                                from: { sharedStateCacheKey in
                                    switch sharedStateCacheKey {
                                    case .count: return .count
                                    case .color: return .color
                                    default: return nil
                                    }
                                },
                                to: { sharedStateEditCacheKey in
                                    switch sharedStateEditCacheKey {
                                    case .count: return .count
                                    case .color: return .color
                                    default: return nil
                                    }
                                }
                            )
                        )
                    )
                },
                label: { Text("Edit") }
            )
        }
    }
}

// MARK: - Screen Preview

struct SharedStateExperimentPreviews: PreviewProvider {
    static var previews: some View {
        NavigationView {
            SharedStateExperiment().screen
        }
    }
}

// MARK: - Edit View

struct SharedStateEditView: View {
    typealias ColorType = SharedStateExperiment.ColorType
    
    enum CacheKey {
        case count // Int
        case color // ColorType
    }
    
    @ObservedObject var store: CacheStore<CacheKey>
    
    var body: some View {
        VStack {
            CounterExperimentScreen(
                store: store.scope(
                    keyTransformation: c.transformer(
                        from: { sharedStateCacheKey in
                            switch sharedStateCacheKey {
                            case .count: return .count
                            default: return nil
                            }
                        },
                        to: { counterCacheKey in
                            switch counterCacheKey {
                            case .count: return .count
                            default: return nil
                            }
                        }
                    )
                )
            )
        
            
            Picker(
                selection: store.binding(.color, as: ColorType.self),
                content: {
                    Text("Red")
                        .tag(ColorType.red)
                    Text("Green")
                        .tag(ColorType.green)
                    Text("Blue")
                        .tag(ColorType.blue)
                },
                label: {
                    Text("Color")
                }
            )
        }
        .navigationTitle(Text("Edit State"))
    }
}

// MARK: - List View

struct SharedStateListView: View {
    typealias ColorType = SharedStateExperiment.ColorType
    
    enum CacheKey {
        case contentArray // [ColorType]
    }
    
    @ObservedObject var store: CacheStore<CacheKey>
    
    private var listContent: [ColorType] {
        store.resolve(.contentArray)
    }
    
    var body: some View {
        List(listContent, id: \.self) { item in
            item.color
        }
    }
}
