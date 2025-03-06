//
//  ContentView.swift
//  DogsApp
//
//  Created by Ajay Dhandhukiya on 07/05/23.
//

import SwiftUI
import CoreData

struct ContentView: View {
    @Environment(\.managedObjectContext) private var viewContext
    @FetchRequest(
        sortDescriptors: [NSSortDescriptor(keyPath: \Item.timestamp, ascending: true)],
        animation: .default)
    private var items: FetchedResults<Item>

    var body: some View {
        NavigationView {
            List {
                ForEach(items) { item in
                    if let timestamp = item.timestamp {
                        NavigationLink(destination: DetailView(item: item)) {
                            HStack {
                                Text(timestamp, formatter: itemFormatter)
                                if let url = item.image_url, let imageUrl = URL(string: url) {
                                    AsyncImage(
                                        url: imageUrl,
                                        content: { image in
                                            image.resizable()
                                                .aspectRatio(contentMode: .fill)
                                                .frame(width: 20, height: 20)
                                                .clipShape(RoundedRectangle(cornerRadius: 5))
                                        },
                                        placeholder: {
                                            ProgressView()
                                        }
                                    )
                                }
                            }
                        }
                    }
                }
                .onDelete(perform: deleteItems)
            }
            .navigationTitle("First")
            .toolbar {
#if os(iOS)
                ToolbarItem(placement: .navigationBarTrailing) {
                    EditButton()
                }
#endif
                ToolbarItem {
                    Button(action: addNewItem) {
                        Label("Add Item", systemImage: "plus")
                    }
                }
                ToolbarItem {
                    Button(action: deleteAllItems) {
                        Label("Delete all Items", systemImage: "minus")
                    }
                }
            }
        }
    }
    
    private func addNewItem() {
        Task {
            for _ in 0..<5 { // Reduced the batch count for efficiency
                await callAPI()
            }
        }
    }
    
    private func callAPI() async {
        do {
            let fact: Response = try await APIService.shared.makeAPIRequest(
                url: "https://dog.ceo/api/breeds/image/random",
                method: "GET",
                parameters: nil,
                headers: nil
            )
            addItem(url: fact.message)
        } catch {
            print("API request failed with error: \(error)")
        }
    }
    
    private func addItem(url: String?) {
        withAnimation {
            let newItem = Item(context: viewContext)
            newItem.timestamp = Date()
            newItem.image_url = url
            do {
                try viewContext.save()
            } catch {
                print("Failed to save item: \(error)")
            }
        }
    }
    
    private func deleteItems(offsets: IndexSet) {
        withAnimation {
            offsets.map { items[$0] }.forEach(viewContext.delete)
            do {
                try viewContext.save()
            } catch {
                print("Failed to delete items: \(error)")
            }
        }
    }
    
    private func deleteAllItems() {
        withAnimation {
            for item in items {
                viewContext.delete(item)
            }
            do {
                try viewContext.save()
            } catch {
                print("Failed to delete all items: \(error)")
            }
        }
    }
}

struct DetailView: View {
    let item: Item
    
    var body: some View {
        VStack(spacing: 20) {
            if let timestamp = item.timestamp {
                Text("Item at \(timestamp, formatter: itemFormatter)")
            }
            if let url = item.image_url, let imageUrl = URL(string: url) {
                AsyncImage(
                    url: imageUrl,
                    content: { image in
                        image.resizable()
                            .aspectRatio(contentMode: .fill)
                            .frame(width: 200, height: 200)
                            .clipShape(RoundedRectangle(cornerRadius: 10))
                    },
                    placeholder: {
                        ProgressView()
                    }
                )
            }
        }
        .navigationTitle("Detail View")
    }
}

private let itemFormatter: DateFormatter = {
    let formatter = DateFormatter()
    formatter.dateStyle = .short
    formatter.timeStyle = .medium
    return formatter
}()

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView().environment(\ .managedObjectContext, PersistenceController.preview.container.viewContext)
    }
}

struct Response: Codable {
    var message: String?
}
