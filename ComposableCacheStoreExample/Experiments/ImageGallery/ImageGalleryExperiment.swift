//
//  ImageGalleryExperiment.swift
//  ComposableCacheStoreExample
//
//  Created by 0x on 5/14/22.
//

import Combine
import CacheStore
import c
import FlatMany
import o
import SURL
import SwiftUI

// MARK: - Experiment

struct ImageGalleryExperiment: Experiment {
    var id: String { ExperimentIdentifier.imageGallery.rawValue }
    var title: String { "ImageGallery" }
    
    var screen: AnyView {
        AnyView(
            ImageGalleryExperimentScreen(
                imageProvider: LoremPicsumImageProvider(imageSize: CGSize(width: 300, height: 200))
            )
        )
    }
}

protocol ImageProviding {
    func fetchImages() -> AnyPublisher<[UIImage], URLError>
    func fetchImage(id: String) -> AnyPublisher<UIImage?, URLError>
}

struct MockImageProvider: ImageProviding {
    func fetchImages() -> AnyPublisher<[UIImage], URLError> {
        Just(
            .init(
                repeating: UIImage(systemName: "keyboard")!,
                count: 10
            )
        )
        .mapError { (Never) -> URLError in }
        .eraseToAnyPublisher()
    }
    
    func fetchImage(id: String) -> AnyPublisher<UIImage?, URLError> {
        Just(UIImage(systemName: "keyboard.fill")!)
            .mapError { (Never) -> URLError in }
            .eraseToAnyPublisher()
    }
}

struct LoremPicsumImageProvider: ImageProviding {
    let imageSize: CGSize
    
    func fetchImages() -> AnyPublisher<[UIImage], URLError> {
        /*
         {
         "id": "0",
         "author": "Alejandro Escamilla",
         "width": 5616,
         "height": 3744,
         "url": "https://unsplash.com/...",
         "download_url": "https://picsum.photos/..."
         }
         */
        enum JSONKey: String {
            case id, author, width, height, url, download_url
        }
        
        return "https://picsum.photos/v2/list"
            .url!
            .get()
            .map { (data, response) in
                c.JSON<JSONKey>.array(data: data)
            }
            .flatMany { json in
                fetchImage(id: json.resolve(.id))
            }
            .map { $0.compactMap { $0 } }
            .eraseToAnyPublisher()
    }
    
    func fetchImage(id: String) -> AnyPublisher<UIImage?, URLError> {
        Future { promise in
            guard let url = URL(string: "https://picsum.photos/id/\(id)/\(Int(imageSize.width))/\(Int(imageSize.height))") else {
                promise(.failure(URLError(.badURL)))
                return
            }
            
            o.url.in(
                url: url,
                successHandler: { (imageData: Data, response) in
                    guard let image = UIImage(data: imageData) else {
                        promise(.failure(URLError(.cannotDecodeRawData)))
                        return
                    }
                    
                    promise(.success(image))
                },
                errorHandler: { _ in promise(.failure(URLError(.badServerResponse))) },
                decodingErrorHandler: { _ in promise(.failure(URLError(.cannotDecodeContentData))) }
            )
        }
        .eraseToAnyPublisher()
    }
}

// MARK: - Screen

struct ImageGalleryExperimentScreen: View {
    enum CacheKey {
        case images // [UIImage]
        
        case isSearchPresented // Bool
        case bag // Set
    }
    
    @ObservedObject var store: CacheStore<CacheKey> = CacheStore(
        initialValues: [
            .isSearchPresented: false,
            .bag: Set<AnyCancellable>()
        ]
    )
    
    let imageProvider: ImageProviding
    
    private var images: [UIImage]? {
        store.get(.images)
    }
    
    private var bag: Set<AnyCancellable> { store.resolve(.bag) }
    
    var body: some View {
        if let images = images {
            List(images, id: \.self) { image in
                Image(uiImage: image)
                    .resizable()
                    .aspectRatio(contentMode: .fill)
                    .frame(maxWidth: .infinity)
                    .cornerRadius(8)
                    .swipeActions(
                        edge: .trailing,
                        allowsFullSwipe: false,
                        content: {
                            Button("Favorite", action: {})
                                .tint(.yellow)
                            Button("Save", action: {})
                                .tint(.blue)
                        }
                    )
            }
            .toolbar {
                Button(
                    action: { store.set(value: true, forKey: .isSearchPresented) },
                    label: {
                        Image(systemName: "magnifyingglass.circle")
                    }
                )
            }
            .sheet(
                isPresented: store.binding(.isSearchPresented),
                content: {
                    SearchView(
                        searchStore: CacheStore(
                            initialValues: [
                                .query: "",
                                .search: { (query: String) in
                                    var bag = self.bag
                                    
                                    imageProvider
                                        .fetchImage(id: query)
                                        .receive(on: DispatchQueue.main)
                                        .sink(
                                            receiveCompletion: { _ in },
                                            receiveValue: { image in
                                                store.set(value: [image], forKey: .images)
                                            }
                                        )
                                        .store(in: &bag)
                                    
                                    store.set(value: bag, forKey: .bag)
                                }
                            ]
                        )
                    )
                }
            )
            .listStyle(PlainListStyle())
            .refreshable {
                reloadData()
            }
        } else {
            ProgressView()
                .onAppear {
                    reloadData()
                }
        }
    }
    
    private func reloadData() {
        var bag = self.bag
        
        imageProvider
            .fetchImages()
            .receive(on: DispatchQueue.main)
            .sink(
                receiveCompletion: { _ in },
                receiveValue: { images in
                    store.set(value: images, forKey: .images)
                }
            )
            .store(in: &bag)
        
        store.set(value: bag, forKey: .bag)
    }
}

// MARK: - Screen Preview

struct ImageGalleryExperimentPreviews: PreviewProvider {
    static var previews: some View {
        ImageGalleryExperiment().screen
    }
}

struct SearchView: View {
    enum SearchCacheKey {
        case query
        
        // Function
        case search // (String) -> Void
    }
    
    @ObservedObject var searchStore: CacheStore<SearchCacheKey>
    
    var body: some View {
        VStack {
            TextField("Search", text: searchStore.binding(.query))
            Button("Search") {
                searchStore.resolve(.search, as: ((String) -> Void).self)(searchStore.resolve(.query))
            }
        }
    }
}
