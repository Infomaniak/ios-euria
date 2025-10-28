/*
 Infomaniak Euria - iOS App
 Copyright (C) 2025 Infomaniak Network SA

 This program is free software: you can redistribute it and/or modify
 it under the terms of the GNU General Public License as published by
 the Free Software Foundation, either version 3 of the License, or
 (at your option) any later version.

 This program is distributed in the hope that it will be useful,
 but WITHOUT ANY WARRANTY; without even the implied warranty of
 MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
 GNU General Public License for more details.

 You should have received a copy of the GNU General Public License
 along with this program.  If not, see <http://www.gnu.org/licenses/>.
 */

import Combine
import EuriaCore
import Foundation
import InfomaniakDI
import SwiftUI

@MainActor
public enum RootViewType: @MainActor Equatable {
    case mainView(MainViewState)
    case preloading
    case onboarding
    case updateRequired
}

@MainActor
public final class RootViewState: ObservableObject {
    @Published public private(set) var state: RootViewType

    private var accountManagerObservation: AnyCancellable?

    public init() {
        state = .preloading

        @InjectService var accountManager: AccountManagerable
        accountManagerObservation = accountManager.objectWillChange
            .receive(on: RunLoop.main)
            .sink { [weak self] in
                self?.transitionToMainViewIfPossible()
            }
    }

    public func transition(toState state: RootViewType, animate: Bool = true) {
        guard animate == true else {
            self.state = state
            return
        }
        withAnimation {
            self.state = state
        }
    }

    private func transitionToMainViewIfPossible() {
        Task {
            @InjectService var accountManager: AccountManagerable
            guard let currentSession = await accountManager.currentSession else {
                transition(toState: .onboarding)
                return
            }

            transition(toState: .mainView(MainViewState(userSession: currentSession)), animate: false)
        }
    }
}
