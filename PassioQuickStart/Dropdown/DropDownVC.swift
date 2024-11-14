//
//  DropDownVC.swift
//  PassioQuickStart
//
//  Created by Pratik on 28/10/24.
//

import UIKit

public protocol DropDownDelegate: AnyObject {
    func onPickerSelection(value: String, selectedIndex: Int)
}

public struct DropDownElement {
    
    var title: String?
    var image: UIImage?
    
    public init(title: String? = nil, image: UIImage? = nil) {
        self.title = title
        self.image = image
    }
}

final public class DropDownVC: UIViewController {

    @IBOutlet weak var pickerTableView: UITableView!

    var viewTag = 0
    var disableCapatlized: Bool = false
    weak var delegate: DropDownDelegate?

    var pickerItems = [DropDownElement]() {
        didSet {
            pickerTableView.reloadData()
        }
    }
    var pickerFrame = CGRect(x: 110, y: 100, width: 288, height: 290) {
        didSet {
            pickerTableView.frame = pickerFrame.height > 358 ? CGRect(
                x: pickerFrame.origin.x,
                y: pickerFrame.origin.y,
                width: pickerFrame.width,
                height: 358
            ) : pickerFrame
        }
    }

    public override func viewDidLoad() {
        super.viewDidLoad()
        configureUI()
    }
    
    private func configureUI() {
        self.view.backgroundColor = UIColor.black.withAlphaComponent(0.4)
        pickerTableView.registerNib(DropDownCell.self)
        pickerTableView.layer.cornerRadius = 8
        pickerTableView.layer.masksToBounds = true
        pickerTableView.clipsToBounds = true
        pickerTableView.estimatedRowHeight = UITableView.automaticDimension
        pickerTableView.frame = pickerFrame
        pickerTableView.dataSource = self
        pickerTableView.delegate = self
    }
    
    @IBAction func onDismissButtonClicked(_ sender: UIButton) {
        dismiss(animated: true)
    }
}

// MARK: - UITableViewDataSource & UITableViewDelegate
extension DropDownVC: UITableViewDataSource, UITableViewDelegate {

    public func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        pickerItems.count
    }

    public func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {

        let cell = tableView.dequeue(DropDownCell.self, for: indexPath)
        let element = pickerItems[indexPath.row]
        cell.configure(element: element, disableCapatlized: disableCapatlized)
        return cell
    }

    public func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        dismiss(animated: true) { [weak self] in
            guard let self else { return }
            delegate?.onPickerSelection(value: pickerItems[indexPath.row].title ?? "",
                                        selectedIndex: indexPath.row)
        }
    }
}
