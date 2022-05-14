//
//  FavoritePostsExperiment.swift
//  ComposableCacheStoreExample
//
//  Created by 0x on 5/12/22.
//

import c
import CacheStore
import o
import SwiftUI

// MARK: - Experiment

struct FavoritePostsExperiment: Experiment {
    var id: String { ExperimentIdentifier.favoritePosts.rawValue }
    var title: String { "Favorite Posts" }
    
    var screen: AnyView {
        AnyView(FavoritePostsExperimentScreen())
    }
    
    struct Post: Identifiable, Codable {
        var userId: Int
        var id: Int
        var title: String
        var body: String
    }
}

// MARK: - Screen

struct FavoritePostsExperimentScreen: View {
    enum Tab {
        case posts, favorites
    }
    
    enum CacheKey {
        case currentTabSelection // Tab
        
        case posts // [Post]
        case favorites // [Post] || [String]
    }
    
    @ObservedObject var store: CacheStore<CacheKey> = CacheStore(
        initialValues: [
            .currentTabSelection: Tab.favorites
        ]
    )
    
    var body: some View {
        TabView(selection: store.binding(.currentTabSelection, as: Tab.self)) {
            postList
            .tabItem { Text("Posts") }
            .tag(Tab.posts)
            
            favoritesList
                .tabItem { Text("Favorites") }
                .tag(Tab.favorites)
        }
    }
    
    private var postList: some View {
        FPEPostsListView(
            store: store.scope(
                keyTransformation: c.transformer(
                    from: { global in
                        switch global {
                        case .posts: return .posts
                        default: return nil
                        }
                    },
                    to: { local in
                        switch local {
                        case .posts: return .posts
                        default: return nil
                        }
                    }
                ),
                defaultCache: [
                    .isFavorite: { (post: FavoritePostsExperiment.Post) -> Bool in
                        let favorites: [FavoritePostsExperiment.Post] = store.get(.favorites) ?? []
                        
                        return favorites.contains(where: { $0.id == post.id })
                    },
                    .fetchPosts: {
                        o.url.in(
                            url: URL(string: "https://jsonplaceholder.typicode.com/posts")!,
                            successHandler: { (posts: [FavoritePostsExperiment.Post], response) in
                                store.set(value: [posts.randomElement()!] + posts, forKey: .posts)
                            }
                        )
                    },
                    .addFavorite: { (post: FavoritePostsExperiment.Post) in
                        var favorites: [FavoritePostsExperiment.Post] = store.get(.favorites) ?? []
                        
                        if let index = favorites.firstIndex(where: { $0.id == post.id }) {
                            favorites.remove(at: index)
                        } else {
                            favorites.append(post)
                        }
                        
                        store.set(value: favorites, forKey: .favorites)
                    }
                ]
            )
        )
    }
    
    private var favoritesList: some View {
        FPEFavoritesListView(
            store: store.scope(
                keyTransformation: c.transformer(
                    from: { global in
                        switch global {
                        case .favorites: return .favorites
                        default: return nil
                        }
                    },
                    to: { local in
                        switch local {
                        case .favorites: return .favorites
                        default: return nil
                        }
                    }
                ),
                defaultCache: [
                    .removeFavorite: { (post: FavoritePostsExperiment.Post) in
                        var favorites: [FavoritePostsExperiment.Post] = store.get(.favorites) ?? []
                        
                        if let index = favorites.firstIndex(where: { $0.id == post.id }) {
                            favorites.remove(at: index)
                        }
                        
                        store.set(value: favorites, forKey: .favorites)
                    }
                ]
            )
        )
    }
}

// MARK: - Screen Preview

struct FavoritePostsExperimentPreviews: PreviewProvider {
    static var previews: some View {
        FavoritePostsExperiment().screen
    }
}

// MARK: - Posts View

struct FPEPostsListView: View {
    enum CacheKey {
        case posts // [Post]
        
        // Funtions
        case isFavorite // (Post) -> Bool
        case addFavorite // (Post) -> Void
        case fetchPosts // () -> Void
    }
    
    @ObservedObject var store: CacheStore<CacheKey>
    
    private var currentPosts: [FavoritePostsExperiment.Post]? {
        store.get(.posts)
    }
    
    private var addFavorite: (FavoritePostsExperiment.Post) -> Void {
        store.resolve(.addFavorite)
    }
    
    private var isFavorite: (FavoritePostsExperiment.Post) -> Bool {
        store.resolve(.isFavorite)
    }
    
    private var fetchPosts: () -> Void {
        store.resolve(.fetchPosts)
    }
    
    var body: some View {
        Group {
            if let currentPosts = currentPosts {
                List(currentPosts) { post in
                    HStack {
                        Text(post.title)
                            .onTapGesture {
                                addFavorite(post)
                            }
                        
                        Spacer()
                        
                        if isFavorite(post) {
                            Image(systemName: "heart")
                        }
                    }
                }
            } else {
                ProgressView()
            }
        }
        .onAppear {
            fetchPosts()
        }
    }
}

// MARK: - Favorites View

struct FPEFavoritesListView: View {
    enum CacheKey {
        case favorites // [Post]
        
        // Funtions
        case removeFavorite // (Post) -> Void
    }
    
    @ObservedObject var store: CacheStore<CacheKey>
    
    private var favorites: [FavoritePostsExperiment.Post] {
        store.get(.favorites) ?? []
    }
    
    private var removeFavorite: (FavoritePostsExperiment.Post) -> Void {
        store.resolve(.removeFavorite)
    }
    
    var body: some View {
        List(favorites) { favorite in
            Text(favorite.title)
                .onTapGesture {
                    removeFavorite(favorite)
                }
        }
    }
}
