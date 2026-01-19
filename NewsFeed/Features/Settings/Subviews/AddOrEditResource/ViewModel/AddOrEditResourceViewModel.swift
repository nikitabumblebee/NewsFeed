//
//  AddOrEditResourceViewModel.swift
//  NewsFeed
//
//  Created by Nikita Shmelev on 17.01.2026.
//

import Combine
import Foundation

class AddOrEditResourceViewModel: Observable {
    private(set) var name: String = ""
    private(set) var url: String = ""
    private var enableResource: Bool = true

    private let validationSubject = CurrentValueSubject<Bool, Never>(false)
    var validationPublisher: AnyPublisher<Bool, Never> {
        validationSubject.eraseToAnyPublisher()
    }

    private(set) var resource: NewsResource?

    private var validation: Bool {
        guard !name.isEmpty, !url.isEmpty else { return false }
        return true
    }

    init(resource: NewsResource?) {
        self.resource = resource
        self.name = resource?.name ?? ""
        self.url = resource?.url ?? ""
        self.enableResource = resource?.show ?? true
        validationSubject.send(validation)
    }

    func updateName(_ name: String) {
        self.name = name.trimmingCharacters(in: .whitespacesAndNewlines)
        validationSubject.send(validation)
    }

    func updateUrl(_ url: String) {
        self.url = url.trimmingCharacters(in: .whitespacesAndNewlines)
        validationSubject.send(validation)
    }

    func save() {
        print("Saving resource with name: \(name) and url: \(url)")
        resource = NewsResource(name: name, url: url, show: enableResource)
    }
}
