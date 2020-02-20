//
//  ScriptsTableViewController.swift
//  Extension
//
//  Created by Ana Caroline de Souza on 16/02/20.
//  Copyright © 2020 Ana e Leo Corp. All rights reserved.
//

import UIKit

protocol ScriptsTableViewControllerDelegate: class {
    
    func didSelected(userScript:UserScript)
    
}

class ScriptsTableViewController: UITableViewController {
    
    var userScripts: [UserScript]!
    var userScriptsDefaultsKey: String!
    weak var delegate: ScriptsTableViewControllerDelegate?
    
    
    override func viewDidLoad() {
        super.viewDidLoad()

        loadUserScriptsFromDefaults()
        
    }
    
    func loadUserScriptsFromDefaults() {
         
         let defaults = UserDefaults.standard
         
         if let userScriptsData = defaults.object(forKey: userScriptsDefaultsKey) as? Data{
             let jsonDecoder = JSONDecoder()
             do {
                 self.userScripts = try jsonDecoder.decode([UserScript].self, from: userScriptsData)
             } catch {
                 print("errrroooorr")
             }
         }
     }

  override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
    return userScripts.count
  }
  
  override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
      let cell = tableView.dequeueReusableCell(withIdentifier: "scriptName", for: indexPath)
      cell.textLabel?.text = userScripts[indexPath.row].name
      return cell
  }
  
  override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {

    delegate?.didSelected(userScript: userScripts[indexPath.row])
    dismiss(animated: true)
    
  }

}
