//
//  AddOrEditResourceViewController.swift
//  NewsFeed
//
//  Created by Nikita Shmelev on 17.01.2026.
//

import Combine
import UIKit

class AddOrEditResourceViewController: BaseViewController {
    @IBOutlet private var nameLabel: UILabel!
    @IBOutlet private var nameTextField: UITextField!
    @IBOutlet private var urlLabel: UILabel!
    @IBOutlet private var urlTextField: UITextField!
    @IBOutlet private var saveButton: UIButton!

    private let navigator: Navigator

    let viewModel: AddOrEditResourceViewModel

    var onSave: ((NewsResource?) -> Void)?

    init(viewModel: AddOrEditResourceViewModel, navigator: Navigator) {
        self.viewModel = viewModel
        self.navigator = navigator
        super.init(nibName: nil, bundle: nil)
    }

    @available(*, unavailable)
    @MainActor required init?(coder _: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
        subscribeToViewModel()
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        navigationController?.setNavigationBarHidden(false, animated: false)
    }

    private func setupUI() {
        navigationItem.title = viewModel.resource == nil ? "New Resource" : "Edit Resource"
        nameTextField.text = viewModel.name
        urlTextField.text = viewModel.url
        let tapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(tapOnView(_:)))
        view.addGestureRecognizer(tapGestureRecognizer)
    }

    private func subscribeToViewModel() {
        viewModel.validationPublisher
            .sink { [weak self] in
                self?.saveButton.isEnabled = $0
            }
            .store(in: &cancellables)
    }

    @IBAction private func onNameTextFieldChange(_ sender: UITextField) {
        viewModel.updateName(sender.text ?? "")
    }

    @IBAction func onUrlTextFieldChange(_ sender: UITextField) {
        viewModel.updateUrl(sender.text ?? "")
    }

    @IBAction private func tapOnSaveButton(_: Any) {
        viewModel.save()
        onSave?(viewModel.resource)
        navigator.popViewController()
    }

    @objc private func tapOnView(_: UITapGestureRecognizer) {
        view.endEditing(true)
    }
}
