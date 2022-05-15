//
//  ScreenDataExperiment.swift
//  ComposableCacheStoreExample
//
//  Created by 0x on 5/14/22.
//

import CacheStore
import Chronicle
import ScreenData
import ScreenDataNavigation
import ScreenDataApp
import ScreenDataUI
import SwiftUI

// MARK: - Experiment

struct ScreenDataExperiment: Experiment {
    var id: String { ExperimentIdentifier.screenData.rawValue }
    var title: String { "ScreenData" }
    
    var screen: AnyView {
        AnyView(ScreenDataExperimentScreen())
    }
}

// MARK: - Screen

struct ScreenDataExperimentScreen: View {
    enum CacheKey {
        case baseID
        case title
        case subtitle
        case bodyText
        
        case isScreenDataPresented
    }
    
    @ObservedObject var store: CacheStore<CacheKey> = CacheStore(
        initialValues: [
            .baseID: "",
            .title: "",
            .subtitle: "",
            .bodyText: "",
            .isScreenDataPresented: false
        ]
    )
    
    var body: some View {
        VStack {
            ScrollView {
                VStack(alignment: .center) {
                    TextField("Base ID", text: store.binding(.baseID))
                    TextField("Title", text: store.binding(.title))
                    TextField("Subtitle", text: store.binding(.subtitle))
                    TextField("Body Text", text: store.binding(.bodyText))
                }
                .padding()
            }
            
            Button("Show ScreenData") { store.set(value: true, forKey: .isScreenDataPresented) }
                .padding()
        }
        .sheet(
            isPresented: store.binding(.isScreenDataPresented),
            content: {
                ScreenDataExample(
                    screenDataApp: DefaultScreenDataApp(
                        baseID: store.resolve(.baseID),
                        isDebugging: true,
                        screenProvider: MockScreenProvider(
                            mockScreen: SomeScreen(
                                id: store.resolve(.baseID),
                                title: store.resolve(.baseID),
                                backgroundColor: .init(red: 1, green: 1, blue: 1),
                                someView: SomeContainerView(
                                    isScrollable: true,
                                    axis: .vertical,
                                    views: [
                                        SomeLabel(
                                            title: store.resolve(.title),
                                            subtitle: store.resolve(.subtitle),
                                            font: .title
                                        ).someView,
                                        
                                        SomeText(title: store.resolve(.bodyText)).someView
                                    ]
                                        .shuffled()
                                ).someView
                            )
                        )
                    )
                )
            }
        )
    }
}

// MARK: - Screen Preview

struct ScreenDataExperimentPreviews: PreviewProvider {
    static var previews: some View {
        ScreenDataExperiment().screen
    }
}


struct ScreenDataExample: View {
    let screenDataApp: DefaultScreenDataApp
    var body: some View { screenDataApp.rootView }
}
