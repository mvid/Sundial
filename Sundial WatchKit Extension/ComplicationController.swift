//
//  ComplicationController.swift
//  Sundial WatchKit Extension
//
//  Created by Mantas Vidutis on 11/12/19.
//  Copyright © 2019 Mantas Vidutis. All rights reserved.
//

import ClockKit
import WatchKit


class ComplicationController: NSObject, CLKComplicationDataSource {
    
    // MARK: - Timeline Configuration
    
    func getSupportedTimeTravelDirections(for complication: CLKComplication, withHandler handler: @escaping (CLKComplicationTimeTravelDirections) -> Void) {
        handler([.forward, .backward])
    }
    
    func getTimelineStartDate(for complication: CLKComplication, withHandler handler: @escaping (Date?) -> Void) {
        let calendar = Calendar.current
        let startDate = calendar.date(byAdding: .day, value: -7, to: Date())
        handler(startDate)
    }
    
    func getTimelineEndDate(for complication: CLKComplication, withHandler handler: @escaping (Date?) -> Void) {
        let calendar = Calendar.current
        let endDate = calendar.date(byAdding: .day, value: 7, to: Date())
        handler(endDate)
    }
    
    func getPrivacyBehavior(for complication: CLKComplication, withHandler handler: @escaping (CLKComplicationPrivacyBehavior) -> Void) {
        handler(.showOnLockScreen)
    }
    
    // MARK: - Timeline Population
    
    func getTemplate(for complication:CLKComplication, date:Date) -> CLKComplicationTemplate? {
        let locationManager = LocationManager()
        let offsetDate = locationManager.locationOffsetDate(date: date)
        let reverseOffsetDate = locationManager.locationReverseOffsetDate(date: date)
        
        switch complication.family {
        case .modularSmall:
            let template = CLKComplicationTemplateModularSmallSimpleText()
            template.textProvider = CLKTimeTextProvider(date:offsetDate)
            return template
        case .modularLarge:
            return nil
        case .circularSmall:
            let template = CLKComplicationTemplateCircularSmallSimpleText()
            template.textProvider = CLKRelativeDateTextProvider(date:reverseOffsetDate, style: .offsetShort, units: .minute)
            return template
        case .graphicCircular:
            let template = CLKComplicationTemplateGraphicCircularStackText()
            let calendar = Calendar.current
            template.line1TextProvider = CLKSimpleTextProvider(text: String(calendar.component(.hour, from: offsetDate)))
            template.line2TextProvider = CLKSimpleTextProvider(text: String(calendar.component(.minute, from: offsetDate)))
            return template
        case .graphicBezel:
            let circularTemplate = CLKComplicationTemplateGraphicCircularStackText()
            let calendar = Calendar.current
            circularTemplate.line1TextProvider = CLKSimpleTextProvider(text: String(calendar.component(.hour, from: offsetDate)))
            circularTemplate.line2TextProvider = CLKSimpleTextProvider(text: String(calendar.component(.minute, from: offsetDate)))
            let template = CLKComplicationTemplateGraphicBezelCircularText()
            template.circularTemplate = circularTemplate
            template.textProvider = CLKTimeTextProvider(date:offsetDate)
            return template
        case .graphicCorner:
            let template = CLKComplicationTemplateGraphicCornerStackText()
            template.innerTextProvider = CLKRelativeDateTextProvider(date:reverseOffsetDate, style: .offset, units: .minute)
            template.outerTextProvider = CLKTimeTextProvider(date:offsetDate)
            return template
        case .graphicRectangular:
            let template = CLKComplicationTemplateGraphicRectangularTextGauge()
            template.body1TextProvider = CLKTimeTextProvider(date:offsetDate)
            template.headerTextProvider = CLKSimpleTextProvider(text:"CHANGE ME")
            template.gaugeProvider = CLKSimpleGaugeProvider(style: .fill, gaugeColor: .red, fillFraction: 0.5)
            return template
        case .utilitarianSmall:
            let template = CLKComplicationTemplateUtilitarianSmallRingText()
            template.textProvider = CLKRelativeDateTextProvider(date:reverseOffsetDate, style: .offsetShort, units: .minute)
            return template
        case .utilitarianSmallFlat:
            let template = CLKComplicationTemplateUtilitarianSmallFlat()
            template.textProvider = CLKRelativeDateTextProvider(date:reverseOffsetDate, style: .offset, units: .minute)
            return template
        case .utilitarianLarge:
            let template = CLKComplicationTemplateUtilitarianLargeFlat()
            template.textProvider = CLKTimeTextProvider(date:offsetDate)
            return template
        case .extraLarge:
            let template = CLKComplicationTemplateExtraLargeStackText()
            template.line1TextProvider = CLKTimeTextProvider(date:offsetDate)
            template.line2TextProvider = CLKRelativeDateTextProvider(date:reverseOffsetDate, style: .offsetShort, units: .minute)
            return template
        default:
            return nil
        }
    }
    
    func getComplicationTimelineEntryForDate(date:Date, complication: CLKComplication) -> CLKComplicationTimelineEntry? {
        let template = self.getTemplate(for: complication, date: date)
        if template != nil {
            return CLKComplicationTimelineEntry(date: date, complicationTemplate: template!)
        } else {
            return nil
        }
    }
    
    func getCurrentTimelineEntry(for complication: CLKComplication, withHandler handler: @escaping (CLKComplicationTimelineEntry?) -> Void) {
        
        // Call the handler with the current timeline entry
        let entry = self.getComplicationTimelineEntryForDate(date: Date(), complication: complication)
        handler(entry)
    }
    
    func getTimelineEntries(for complication: CLKComplication, before date: Date, limit: Int, withHandler handler: @escaping ([CLKComplicationTimelineEntry]?) -> Void) {
        // Call the handler with the timeline entries prior to the given date
        let calendar = Calendar.current
        var entries = [CLKComplicationTimelineEntry]()
        
        for i in 0...limit {
            let followingDate = calendar.date(byAdding: .minute, value: -(i + 1), to: date)
            let entry = getComplicationTimelineEntryForDate(date: followingDate!, complication: complication)
            if entry != nil {
                entries.append(entry!)
            }
        }
        
        handler(entries)
    }
    
    func getTimelineEntries(for complication: CLKComplication, after date: Date, limit: Int, withHandler handler: @escaping ([CLKComplicationTimelineEntry]?) -> Void) {
        // Call the handler with the timeline entries after to the given date
        let calendar = Calendar.current
        var entries = [CLKComplicationTimelineEntry]()
        
        for i in 0...limit {
            let followingDate = calendar.date(byAdding: .minute, value: i + 1, to: date)
            let entry = getComplicationTimelineEntryForDate(date: followingDate!, complication: complication)
            if entry != nil {
                entries.append(entry!)
            }
        }
        
        handler(entries)
    }
    
    // MARK: - Placeholder Templates
    
    func getLocalizableSampleTemplate(for complication: CLKComplication, withHandler handler: @escaping (CLKComplicationTemplate?) -> Void) {
        // This method will be called once per supported complication, and the results will be cached
        handler(getTemplate(for: complication, date: Date()))
    }
}
