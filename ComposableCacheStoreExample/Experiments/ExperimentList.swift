//
//  ExperimentList.swift
//  ComposableCacheStoreExample
//
//  Created by 0x on 5/11/22.
//

import SwiftUI

struct ExperimentList: View {
    let experiments: [Experiment]
    
    var body: some View {
        List(experiments, id: \.id) { experiment in
            NavigationLink(
                destination: {
                    experiment.screen
                        .navigationTitle(Text(experiment.title))
                },
                label: {
                    Text(experiment.title)
                }
            )
        }
        .navigationTitle(Text("Twitch Experiments"))
    }
}

struct ExperimentList_Previews: PreviewProvider {
    static var previews: some View {
        NavigationView {
            ExperimentList(
                experiments: ExperimentIdentifier.allCases.map(\.experiment)
            )
        }
    }
}
