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

import EuriaCore
import EuriaCoreUI
import InfomaniakCore
import InfomaniakDI
import SwiftUI

public struct MainView: View {
    @LazyInjectService private var accountManager: AccountManagerable

    @EnvironmentObject private var rootViewState: RootViewState
    @EnvironmentObject private var mainViewState: MainViewState

    public init() {}

    public var body: some View {
        NavigationStack {
            WebView(url: URL(string: "https://\(ApiEnvironment.current.euriaHost)/")!)
                .toolbar {
                    Button("Disconnect") {
                        Task {
                            await accountManager.removeTokenAndAccountFor(userId: mainViewState.userSession.userId)
                            rootViewState.transition(toState: .onboarding)
                        }
                    }
                }
        }
    }
}

#Preview {
    MainView()
}
