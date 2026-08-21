//
//  Color+Extension.swift
//  EstacioneAqui
//  Created by Pedro Teloeken on 26/06/26.
//  Copyright © 2026 teloeken. All rights reserved.
//


import SwiftUI
import UIKit

extension Color {
    static let primaryBlue = Color(uiColor: UIColor { traits in
        traits.userInterfaceStyle == .dark
            ? UIColor(red: 127 / 255, green: 163 / 255, blue: 232 / 255, alpha: 1)
            : UIColor(red: 13 / 255, green: 32 / 255, blue: 79 / 255, alpha: 1)
    })

    static let onPrimaryBlue = Color(uiColor: UIColor { traits in
        traits.userInterfaceStyle == .dark
            ? UIColor(red: 10 / 255, green: 20 / 255, blue: 40 / 255, alpha: 1)
            : .white
    })

    static let secondaryBlue = Color(uiColor: UIColor { traits in
        traits.userInterfaceStyle == .dark
            ? UIColor(red: 16 / 255, green: 24 / 255, blue: 43 / 255, alpha: 1)
            : UIColor(red: 242 / 255, green: 246 / 255, blue: 255 / 255, alpha: 1)
    })

    static let fieldSurface = Color(uiColor: UIColor { traits in
        traits.userInterfaceStyle == .dark
            ? UIColor.white.withAlphaComponent(0.10)
            : .clear
    })

    static let elevationShadow = Color(uiColor: UIColor { traits in
        traits.userInterfaceStyle == .dark
            ? UIColor.black.withAlphaComponent(0.6)
            : UIColor.black.withAlphaComponent(0.12)
    })
}
