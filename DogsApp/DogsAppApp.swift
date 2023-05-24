//
//  DogsAppApp.swift
//  DogsApp
//
//  Created by Ajay Dhandhukiya on 07/05/23.
//

import SwiftUI

@main
struct DogsAppApp: App {
    let persistenceController = PersistenceController.shared

    var body: some Scene {
        WindowGroup {
            ContentView()
                .environment(\.managedObjectContext, persistenceController.container.viewContext)
        }
    }
}
