//
//  ReadSelectorView.swift
//  NewsFeed
//
//  Created by Nikita Shmelev on 14.01.2026.
//

import UIKit
import Combine

class ReadSelectorView: UIView {
    @IBOutlet private var segmentedControl: UISegmentedControl!
    
    private let readSelectionChangeSubject: CurrentValueSubject<ReadSelectorViewType, Never> = .init(ReadSelectorViewType(rawValue: UserDefaults.standard.selectedNewsPresentationType) ?? .short)
    var readSelectionChangePublisher: AnyPublisher<ReadSelectorViewType, Never> {
        readSelectionChangeSubject.eraseToAnyPublisher()
    }

    override nonisolated func awakeFromNib() {
        super.awakeFromNib()
        MainActor.assumeIsolated {
            segmentedControl.selectedSegmentIndex = UserDefaults.standard.selectedNewsPresentationType
        }
    }

    @IBAction func onValueChange(_ sender: UISegmentedControl) {
        let readSelectorViewType = ReadSelectorViewType(rawValue: sender.selectedSegmentIndex) ?? .short
        UserDefaults.standard.selectedNewsPresentationType = readSelectorViewType.rawValue
        readSelectionChangeSubject.send(readSelectorViewType)
    }
}

enum ReadSelectorViewType: Int {
    case short = 0
    case extended
}
