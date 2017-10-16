//
//  ComplicationController.swift
//  watchTracker Extension
//
//  Created by Mark Presley on 10/13/17.
//  Copyright © 2017 Mark Presley. All rights reserved.
//

import ClockKit
import WatchKit

class ComplicationController: NSObject, CLKComplicationDataSource {
    
    var selectedContact: Contact? {
        return (WKExtension.shared().delegate as? ExtensionDelegate)?.selectedContact
    }
    
    // MARK: - Timeline Configuration
    
    func getSupportedTimeTravelDirections(for complication: CLKComplication, withHandler handler: @escaping (CLKComplicationTimeTravelDirections) -> Void) {
        handler([.forward, .backward])
    }
    
    func getTimelineStartDate(for complication: CLKComplication, withHandler handler: @escaping (Date?) -> Void) {
        handler(nil)
    }
    
    func getTimelineEndDate(for complication: CLKComplication, withHandler handler: @escaping (Date?) -> Void) {
        handler(nil)
    }
    
    func getPrivacyBehavior(for complication: CLKComplication, withHandler handler: @escaping (CLKComplicationPrivacyBehavior) -> Void) {
        handler(.showOnLockScreen)
    }
    
    // MARK: - Timeline Population
    
    func getCurrentTimelineEntry(for complication: CLKComplication, withHandler handler: @escaping (CLKComplicationTimelineEntry?) -> Void) {

        var template: CLKComplicationTemplate?

        switch complication.family {
        case .modularSmall:
            template = nil
        case .modularLarge:
            template = getModularLargeActiveTemplate()
        case .utilitarianSmall:
            template = nil
        case .utilitarianSmallFlat:
            template = nil
        case .utilitarianLarge:
            template = nil
        case .circularSmall:
            template = nil
        case .extraLarge:
            template = nil
        }
        handler(template != nil ? CLKComplicationTimelineEntry(date: Date(), complicationTemplate: template!) : nil)
    }
    
    func getTimelineEntries(for complication: CLKComplication, before date: Date, limit: Int, withHandler handler: @escaping ([CLKComplicationTimelineEntry]?) -> Void) {
        // Call the handler with the timeline entries prior to the given date
        handler(nil)
    }
    
    func getTimelineEntries(for complication: CLKComplication, after date: Date, limit: Int, withHandler handler: @escaping ([CLKComplicationTimelineEntry]?) -> Void) {
        // Call the handler with the timeline entries after to the given date
        handler(nil)
    }
    
    // MARK: - Placeholder Templates
    
    func getLocalizableSampleTemplate(for complication: CLKComplication, withHandler handler: @escaping (CLKComplicationTemplate?) -> Void) {
        
        // This method will be called once per supported complication, and the results will be cached
        var template: CLKComplicationTemplate?
        switch complication.family {
        case .modularSmall:
            template = nil
        case .modularLarge:
            template = getModularLargePlaceholderTemplate()
        case .utilitarianSmall:
            template = nil
        case .utilitarianSmallFlat:
            template = nil
        case .utilitarianLarge:
            template = nil
        case .circularSmall:
            template = nil
        case .extraLarge:
            template = nil
        }
        handler(template)
    }
    
    // MARK: - Templates
    
    private func getModularLargeActiveTemplate() -> CLKComplicationTemplate? {
        let template = getModularLargeTableStartupTemplate()
        template.headerTextProvider = CLKSimpleTextProvider(text: selectedContact?.name ?? "", shortText: selectedContact?.shortName)
        template.body1TextProvider = CLKSimpleTextProvider(text: selectedContact?.location?.region ?? "", shortText: "")
        template.body2TextProvider = CLKSimpleTextProvider(text: "\(selectedContact?.location?.distance ?? 0) leagues", shortText: String(selectedContact?.location?.distance ?? 0))
        return template
    }
    
    private func getModularLargePlaceholderTemplate() -> CLKComplicationTemplate? {
        let template = getModularLargeTableStartupTemplate()
        template.headerTextProvider = CLKSimpleTextProvider(text: "Jon Snow", shortText: "Jon")
        template.body1TextProvider = CLKSimpleTextProvider(text: "Beyond the Wall", shortText: "")
        template.body2TextProvider = CLKSimpleTextProvider(text: "100 leagues", shortText: "100")
        return template
    }
    
    private func getModularLargeTableStartupTemplate() -> CLKComplicationTemplateModularLargeStandardBody {
        let template = CLKComplicationTemplateModularLargeStandardBody()
        template.tintColor = #colorLiteral(red: 0.2392156869, green: 0.6745098233, blue: 0.9686274529, alpha: 1)
        return template
    }
}
