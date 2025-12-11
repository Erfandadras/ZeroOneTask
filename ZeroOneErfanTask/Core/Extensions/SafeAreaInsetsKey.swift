//
//  SafeAreaInsetsKey.swift
//  realstate
//
//  Created by Erfan mac mini on 12/7/24.
//
import SwiftUI


private struct SafeAreaInsetsKey: EnvironmentKey {
    static var defaultValue: UIEdgeInsets {
        UIApplication.shared.windows[0].safeAreaInsets
    }
}

public extension EnvironmentValues {
    
    var safeAreaInsets: UIEdgeInsets {
        self[SafeAreaInsetsKey.self]
    }
}

private extension UIEdgeInsets {
    var insets: EdgeInsets {
        EdgeInsets(top: top, leading: left, bottom: bottom, trailing: right)
    }
}

public extension UIEdgeInsets {
    func bottomPadding(value: CGFloat) -> CGFloat {
        if insets.bottom >= value {
            return insets.bottom
        } else {
            return value
        }
    }
}
