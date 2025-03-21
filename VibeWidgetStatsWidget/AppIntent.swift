//
//  AppIntent.swift
//  VibeWidgetStatsWidget
//
//  Created by Jason Diller on 2025-03-21.
//  Copyright © 2025 gorgias. All rights reserved.
//

import WidgetKit
import AppIntents

struct ConfigurationAppIntent: WidgetConfigurationIntent {
    static var title: LocalizedStringResource { "Configuration" }
    static var description: IntentDescription { "This is an example widget." }

    // An example configurable parameter.
    @Parameter(title: "Favorite Emoji", default: "😃")
    var favoriteEmoji: String
}
