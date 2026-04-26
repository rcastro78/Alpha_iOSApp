//
//  Alpha_inmobiliariaApp.swift
//  Alpha inmobiliaria
//
//  Created by Rafael David Castro Luna on 30/3/26.
//

import SwiftUI

@main
struct AlphaInmobiliariaApp: App {
    @State private var isLoggedIn = false

    var body: some Scene {
        WindowGroup {
            if isLoggedIn {
                MenuView(onLogout: {
                    // Limpiar UserDefaults al cerrar sesión
                    UserDefaults.standard.removePersistentDomain(
                        forName: Bundle.main.bundleIdentifier!
                    )
                    isLoggedIn = false
                })
            } else {
                LoginView(onLoginSuccess: {
                    isLoggedIn = true
                })
            }
        }
    }
}
