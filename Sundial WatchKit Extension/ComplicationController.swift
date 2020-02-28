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
        handler(nil)
    }
    
    func getTimelineEndDate(for complication: CLKComplication, withHandler handler: @escaping (Date?) -> Void) {
        handler(nil)
    }
    
    func getPrivacyBehavior(for complication: CLKComplication, withHandler handler: @escaping (CLKComplicationPrivacyBehavior) -> Void) {
        handler(.showOnLockScreen)
    }
    
    // MARK: - Timeline Population
    
    func getTemplate(for complication:CLKComplication, date:Date) -> CLKComplicationTemplate? {
        let locationManager = LocationManager()
        let offsetDate = locationManager.locationOffsetDate(date: date)
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "HH:mm:ss"
        let dateFormatterShort = DateFormatter()
        dateFormatterShort.dateFormat = "HH:mm"
        
        switch complication.family {
        case .modularSmall:
            let template = CLKComplicationTemplateModularSmallSimpleText()
            template.textProvider = CLKSimpleTextProvider(text: dateFormatter.string(from: offsetDate), shortText: dateFormatterShort.string(from: offsetDate))
            return template
        case .circularSmall:
            let template = CLKComplicationTemplateCircularSmallSimpleText()
            template.textProvider = CLKSimpleTextProvider(text:dateFormatter.string(from: offsetDate), shortText: dateFormatterShort.string(from: offsetDate))
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
            let hour = -(i + 1)
            let followingDate = calendar.date(byAdding: .hour, value: hour, to: date)
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
            let hour = i + 1
            let followingDate = calendar.date(byAdding: .hour, value: hour, to: date)
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
