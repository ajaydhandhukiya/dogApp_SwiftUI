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
                    NavigationLink {
                        VStack(spacing: 60){
                            Text("Item at \(item.timestamp!, formatter: itemFormatter)")
                            if let url = item.image_url{
                                    AsyncImage(
                                        url: URL(string: url),
                                        content: { image in
                                            image.resizable()
                                                .aspectRatio(contentMode: .fill)
                                                .frame(maxWidth: 200, maxHeight: 200)
                                        },
                                        placeholder: {
                                            ProgressView()
                                        }
                                    )
                            }
                        }.navigationTitle("Second")
                    } label: {
                        HStack{
                            Text(item.timestamp!, formatter: itemFormatter)
                            if let url = item.image_url{
                                AsyncImage(
                                    url: URL(string: url),
                                    content: { image in
                                        image.resizable()
                                            .aspectRatio(contentMode: .fill)
                                            .frame(maxWidth: 20, maxHeight: 20)
                                    },
                                    placeholder: {
                                        ProgressView()
                                    }
                                )
                            }
                        }
                    }
                }
                .onDelete(perform: deleteItems)
            }
            
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
            Text("Select an item")
        }.navigationTitle("First")
    }
    private func addNewItem(){
        Task{
            for _ in 0...400 {
                await callAPI()
            }
        }
    }
    private func callAPI() async{
        struct Fact: Codable {
            let length: Int
            let fact: String
            // Add additional properties as per your API response
        }

        Task {
            do {
                let fact: Response = try await APIService.shared.makeAPIRequest(url: "https://dog.ceo/api/breeds/image/random", method: "GET", parameters: nil, headers: nil)
                addItem(url: fact.message)
            } catch {
                print("API request failed with error: \(error)")
            }
        }
        /*
        guard let url = URL(string: "https://dog.ceo/api/breeds/image/random") else {
            print("Invalid URL")
            return
        }
        do {
            let (data, _) = try await URLSession.shared.data(from: url)
            if let decodedResponse = try? JSONDecoder().decode(Response.self, from: data) {
                addItem(url: decodedResponse.message)
            }
            // more code to come
        } catch {
            print("Invalid data")
        }
        */
    }
    
    private func addItem(url:String?) {
        withAnimation(.default) {
            let newItem = Item(context: viewContext)
            newItem.timestamp = Date()
            newItem.image_url = url
            do {
                try viewContext.save()
            } catch {
                // Replace this implementation with code to handle the error appropriately.
                // fatalError() causes the application to generate a crash log and terminate. You should not use this function in a shipping application, although it may be useful during development.
                let nsError = error as NSError
                fatalError("Unresolved error \(nsError), \(nsError.userInfo)")
            }
        }
    }

    private func deleteItems(offsets: IndexSet) {
        withAnimation {
            offsets.map { items[$0] }.forEach(viewContext.delete)

            do {
                try viewContext.save()
            } catch {
                // Replace this implementation with code to handle the error appropriately.
                // fatalError() causes the application to generate a crash log and terminate. You should not use this function in a shipping application, although it may be useful during development.
                let nsError = error as NSError
                fatalError("Unresolved error \(nsError), \(nsError.userInfo)")
            }
        }
    }
    private func deleteAllItems() {
        withAnimation {
            for i in 0...400 {
                IndexSet(integer: i).map { items[$0] }.forEach(viewContext.delete)
            }
            do {
                try viewContext.save()
            } catch {
                // Replace this implementation with code to handle the error appropriately.
                // fatalError() causes the application to generate a crash log and terminate. You should not use this function in a shipping application, although it may be useful during development.
                let nsError = error as NSError
                fatalError("Unresolved error \(nsError), \(nsError.userInfo)")
            }
        }
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
        ContentView().environment(\.managedObjectContext, PersistenceController.preview.container.viewContext)
    }
}
struct Response: Codable {
    var message: String?
}
