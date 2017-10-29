//
//  ListEditorViewController.swift
//  OpenCallBlock
//
//  Created by Chris Ballinger on 10/29/17.
//  Copyright © 2017 Chris Ballinger. All rights reserved.
//

import UIKit
import CallDataKit
import PhoneNumberKit

/// Segue identifiers
enum ListEditorSegue: String {
    case editWhitelist
    case editBlocklist
    
    var editorType: EditorType {
        switch self {
        case .editBlocklist:
            return .blocklist
        case .editWhitelist:
            return .whitelist
        }
    }
}

enum EditorType {
    case invalid
    case whitelist
    case blocklist
}

private enum EditorAction {
    case add
    case remove
}

private struct Constants {
    static let CellIdentifier = "CellIdentifier"
}

class ListEditorViewController: UITableViewController {
    
    private let numberKit = PhoneNumberKit()
    private var editorType: EditorType = .invalid
    private var user: User? = nil {
        didSet {
            guard let user = self.user else { return }
            assert(editorType != .invalid, "Invalid editorType")
            switch editorType {
            case .whitelist:
                self.contacts = user.whitelist
            case .blocklist:
                self.contacts = user.blocklist
            default:
                break
            }
        }
    }
    private var contacts: [Contact] = []
    
    private var addButton: UIBarButtonItem? = nil
    
    public func setupWithUser(_ user: User, editorType: EditorType) {
        // Editor type must be set before setting user
        self.editorType = editorType
        self.user = user
        switch editorType {
        case .whitelist:
            self.title = "Edit Whitelist"
        case .blocklist:
            self.title = "Edit Blocklist"
        default:
            break
        }
        self.tableView.reloadData()
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        assert(self.editorType != .invalid, "Editor setup error!")
    }
    
    @objc func addButtonPressed(_ sender: Any) {
        guard let user = self.user else {
            return
        }
        let alert = UIAlertController(title: "Add Number", message: nil, preferredStyle: .alert)
        alert.addTextField { (textField) in
            textField.keyboardType = .numberPad
            textField.textContentType = UITextContentType.telephoneNumber
            textField.placeholder = "800-555-5555"
        }
        let cancel = UIAlertAction(title: "Cancel", style: .cancel, handler: nil)
        let save = UIAlertAction(title: "Save", style: .default) { (action) in
            guard let numberString = alert.textFields?.first?.text,
                let contact = Contact(numberString: numberString) else {
                return
            }
            self.editContact(contact, user: user, editorType: self.editorType, editAction: .add)
            self.tableView.reloadData()
        }
        alert.addAction(cancel)
        alert.addAction(save)
        present(alert, animated: true, completion: nil)
    }
    
    private func editContact(_ contact: Contact, user: User, editorType: EditorType, editAction: EditorAction) {
        
        var user = user

        switch editorType {
        case .whitelist:
            switch editAction {
            case .add:
                user.addToWhitelist(contact)
            case .remove:
                user.removeFromWhitelist(contact)
            }
        case .blocklist:
            switch editAction {
            case .add:
                user.addToBlocklist(contact)
            case .remove:
                user.removeFromBlocklist(contact)
            }
        default:
            return
        }
        
        // Save the new user data
        self.user = user
        DatabaseManager.shared.user = user
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.addButton = UIBarButtonItem(barButtonSystemItem: .add, target: self, action: #selector(addButtonPressed(_:)))
        self.navigationItem.rightBarButtonItem = self.addButton
        self.tableView.allowsSelection = false
        
        // Uncomment the following line to preserve selection between presentations
        // self.clearsSelectionOnViewWillAppear = false

        // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
        // self.navigationItem.rightBarButtonItem = self.editButtonItem
        self.tableView.register(UITableViewCell.self, forCellReuseIdentifier: Constants.CellIdentifier)
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    // MARK: - Table view data source

    override func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return contacts.count
    }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: Constants.CellIdentifier, for: indexPath)

        let contact = contacts[indexPath.row]
        var prefix = ""
        switch editorType {
        case .blocklist:
            prefix = "🚫"
        case .whitelist:
            prefix = "✅"
        default:
            break
        }
        var numberString = ""
        if let number = contact.phoneNumber(numberKit) {
            numberString = numberKit.format(number, toType: .national, withPrefix: false)
        }
        cell.textLabel?.text = "\(prefix) \(numberString)"

        return cell
    }


    // Override to support conditional editing of the table view.
    override func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        // Return false if you do not want the specified item to be editable.
        return true
    }

    // Override to support editing the table view.
    override func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCellEditingStyle, forRowAt indexPath: IndexPath) {
        guard let user = self.user else { return }
        if editingStyle == .delete {
            let contact = contacts[indexPath.row]
            editContact(contact, user: user, editorType: editorType, editAction: .remove)
            // Delete the row from the data source
            tableView.deleteRows(at: [indexPath], with: .fade)
        } else if editingStyle == .insert {
            // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view
        }    
    }


    /*
    // Override to support rearranging the table view.
    override func tableView(_ tableView: UITableView, moveRowAt fromIndexPath: IndexPath, to: IndexPath) {

    }
    */

    /*
    // Override to support conditional rearranging of the table view.
    override func tableView(_ tableView: UITableView, canMoveRowAt indexPath: IndexPath) -> Bool {
        // Return false if you do not want the item to be re-orderable.
        return true
    }
    */

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

}
