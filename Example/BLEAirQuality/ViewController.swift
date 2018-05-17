//
//  ViewController.swift
//  BLEAirQuality
//
//  Created by Chris Ballinger on 05/16/2018.
//  Copyright (c) 2018 Chris Ballinger. All rights reserved.
//

import Cocoa
import BLEAirQuality

class ViewController: NSViewController {
    @IBOutlet weak var pm2_5: NSTextField!
    @IBOutlet weak var pm10: NSTextField!
    private let sensor = SensorManager()
    private var peripherals = Set<Peripheral>()
    private var timer: Timer?

    override func viewDidLoad() {
        super.viewDidLoad()

        pm2_5.stringValue = "PM2.5: ???"
        pm10.stringValue = "PM10: ???"

        sensor.startScan()
        sensor.scanBlock = { [weak self] (peripheral) in
            self?.peripherals.insert(peripheral)
        }

        let readingBlock: ReadingBlock = { [weak self] (reading, error) in
            guard let reading = reading else {
                if let error = error {
                    debugPrint("Error getting reading... \(error)")
                }
                return
            }
            self?.readingUpdated(reading: reading)
        }

        timer = Timer.scheduledTimer(withTimeInterval: 1, repeats: true, block: { [weak self] (_) in
            // For now just use first peripheral we find
            guard let peripheral = self?.peripherals.first else {
                return
            }
            self?.sensor.fetchReading(from: peripheral, type: .pm2_5, completion: readingBlock)
            self?.sensor.fetchReading(from: peripheral, type: .pm10, completion: readingBlock)
        })
    }

    private func readingUpdated(reading: Reading) {
        switch reading.type {
        case .pm2_5:
            pm2_5.stringValue = "PM2.5: \(reading.value)"
        case .pm10:
            pm10.stringValue = "PM10: \(reading.value)"
        }
    }

    override var representedObject: Any? {
        didSet {
            // Update the view, if already loaded.
        }
    }
}
