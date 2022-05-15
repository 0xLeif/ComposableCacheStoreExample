//
//  SharedStoreStateExperiment.swift
//  ComposableStoreExample
//
//  Created by 0x on 5/14/22.
//

import c
import CacheStore
import SwiftUI

// MARK: - Experiment

struct SharedStoreStateExperiment: Experiment {
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
    
    var id: String { ExperimentIdentifier.sharedStoreState.rawValue }
    var title: String { "Shared Store State" }
    
    var screen: AnyView {
        AnyView(
            SharedStoreStateExperimentScreen(
                store: Store(
                    initialValues: [
                        .count: 0,
                        .color: ColorType.red,
                        .contentArray: []
                    ],
                    actionHandler: StoreActionHandler { store, action, _ in
                        switch action {
                        case .updateContentArray:
                            store.set(
                                value: [ColorType](
                                    repeating: store.resolve(.color, as: ColorType.self),
                                    count: store.resolve(.count)
                                ),
                                forKey: .contentArray
                            )
                        case let .counterAction(action):
                            print("Counter Action: \(action)")
                        }
                    },
                    dependency: ()
                )
            )
        )
    }
}

// MARK: - Screen

struct SharedStoreStateExperimentScreen: View {
    typealias ColorType = SharedStoreStateExperiment.ColorType
    
    enum StoreKey: CaseIterable {
        case count // Int
        case color // ColorType
        case contentArray // [ColorType]
    }
    
    enum Action {
        case updateContentArray
        
        case counterAction(StoreDemoExperimentScreen.Action)
    }
    
    @ObservedObject var store: Store<StoreKey, Action, Void>
    
    private var count: Int {
        store.resolve(.count)
    }
    
    var body: some View {
        Form {
            SharedStoreStateListView(
                store: store.actionlessScope(
                    keyTransformation: c.transformer(
                        from: { sharedStateStoreKey in
                            switch sharedStateStoreKey {
                            case .contentArray: return .contentArray
                            default: return nil
                            }
                        },
                        to: { sharedStateStoreKey in
                            switch sharedStateStoreKey {
                            case .contentArray: return .contentArray
                            default: return nil
                            }
                        }
                    )
                )
            )
        }
        .onAppear {
             store.handle(action: .updateContentArray)
        }
        .toolbar {
            NavigationLink(
                destination: {
                    SharedStoreStateEditView(
                        store: store.scope(
                            keyTransformation: c.transformer(
                                from: { global in
                                    switch global {
                                    case .count: return .count
                                    case .color: return .color
                                    default: return nil
                                    }
                                },
                                to: { local in
                                    switch local {
                                    case .count: return .count
                                    case .color: return .color
                                    default: return nil
                                    }
                                }
                            ),
                            actionHandler: .none,
                            actionTransformation: { localAction in
                                switch localAction {
                                case let .counterAction(action): return .counterAction(action)
                                default: return nil
                                }
                            }
                        )
                    )
                },
                label: { Text("Edit") }
            )
        }
    }
}

// MARK: - Screen Preview

struct SharedStoreStateExperimentPreviews: PreviewProvider {
    static var previews: some View {
        NavigationView {
            SharedStoreStateExperiment().screen
        }
    }
}

// MARK: - Edit View

struct SharedStoreStateEditView: View {
    typealias ColorType = SharedStoreStateExperiment.ColorType
    
    enum StoreKey {
        case count // Int
        case color // ColorType
    }
    
    enum Action {
        case counterAction(StoreDemoExperimentScreen.Action)
    }
    
    @ObservedObject var store: Store<StoreKey, Action, Void>
    
    var body: some View {
        VStack {
            StoreDemoExperimentScreen(
                store: store.scope(
                    keyTransformation: c.transformer(
                        from: { global in
                            switch global {
                            case .count: return .count
                            default: return nil
                            }
                        },
                        to: { local in
                            switch local {
                            case .count: return .count
                            default: return nil
                            }
                        }
                    ),
                    actionHandler: StoreDemoExperimentScreen.actionHandler,
                    actionTransformation: { localAction in
                        guard let localAction = localAction else { return nil }
                        return .counterAction(localAction)
                    }
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

struct SharedStoreStateListView: View {
    typealias ColorType = SharedStoreStateExperiment.ColorType
    
    enum StoreKey {
        case contentArray // [ColorType]
    }
    
    @ObservedObject var store: Store<StoreKey, Void, Void>
    
    private var listContent: [ColorType] {
        store.resolve(.contentArray)
    }
    
    var body: some View {
        List(listContent, id: \.self) { item in
            item.color
        }
    }
}
