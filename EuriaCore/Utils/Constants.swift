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

import Foundation

public enum Constants {
    public static let bundleId = "com.infomaniak.euria"

    public static let appName = Bundle.main.object(forInfoDictionaryKey: "CFBundleName") as! String? ?? "Euria"
    public static let appGroupIdentifier = "group.\(Constants.bundleId)"
    public static let sharedAppGroupName = "group.com.infomaniak"

    private static let appIdentifierPrefix = Bundle.main.infoDictionary!["AppIdentifierPrefix"] as! String
    public static let accessGroup: String = Constants.appIdentifierPrefix + Constants.bundleId
}

public enum DeeplinkConstants {
    public static let newChatURL = URL(string: "euria://widget-new-chat")!
    public static let ephemeralURL = URL(string: "euria://widget-ephemeral")!
    public static let speechURL = URL(string: "euria://widget-speech")!

    public static func importURLFor(uuid: String) -> URL {
        return URL(string: "euria://shareextension-import?session_uuid=\(uuid)")!
    }
}

public enum NavigationConstants {
    public static let ephemeralRoute = "/?ephemeral=true"
    public static let speechRoute = "/?speech=true"
}
