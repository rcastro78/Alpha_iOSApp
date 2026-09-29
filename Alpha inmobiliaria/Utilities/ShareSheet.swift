//
//  ShareSheet.swift
//  Alpha inmobiliaria
//
//  Created by Rafael David Castro Luna on 3/7/26.
//


import SwiftUI

struct ShareSheet: UIViewControllerRepresentable {

    let items: [Any]

    func makeUIViewController(context: Context) -> UIActivityViewController {

        UIActivityViewController(
            activityItems: items,
            applicationActivities: nil
        )
    }

    func updateUIViewController(
        _ uiViewController: UIActivityViewController,
        context: Context
    ) {

    }
}