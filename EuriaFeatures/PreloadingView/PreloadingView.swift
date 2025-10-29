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

import DesignSystem
import EuriaCore
import EuriaCoreUI
import InfomaniakCore
import InfomaniakCoreCommonUI
import InfomaniakCoreSwiftUI
import InfomaniakDI
import SwiftUI

extension VerticalAlignment {
    enum SplashScreenIconAlignment: AlignmentID {
        static func defaultValue(in context: ViewDimensions) -> CGFloat {
            return context[VerticalAlignment.center]
        }
    }

    static let splashScreenIconAlignment = VerticalAlignment(SplashScreenIconAlignment.self)
}

public struct PreloadingView: View {
    @EnvironmentObject private var rootViewState: RootViewState

    public init() {}

    public var body: some View {
        SplashScreenView()
            .task {
                await preloadApp()
            }
    }

    private func preloadApp() async {
        @InjectService var appLaunchCounter: AppLaunchCounter
        guard !appLaunchCounter.isFirstLaunch else {
            @InjectService var tokenStore: TokenStore
            tokenStore.removeAllTokens()
            appLaunchCounter.increase()
            rootViewState.transition(toState: .onboarding)
            return
        }

        @InjectService var accountManager: AccountManagerable
        if let userSession = await accountManager.currentSession {
            rootViewState.transition(toState: .mainView(MainViewState(userSession: userSession)))
        } else {
            rootViewState.transition(toState: .onboarding)
        }
    }
}

#Preview {
    PreloadingView()
        .environmentObject(RootViewState())
}
