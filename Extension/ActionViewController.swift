//
//  ActionViewController.swift
//  Extension
//
//  Created by Ana Caroline de Souza on 15/02/20.
//  Copyright © 2020 Ana e Leo Corp. All rights reserved.
//

import UIKit
import MobileCoreServices

class ActionViewController: UIViewController, ScriptsTableViewControllerDelegate {
    
    func didSelected(userScript: UserScript) {
        script.text = userScript.script
    }
    

    @IBOutlet var script: UITextView!
    var pageTitle = ""
    var pageURL = ""
    var userDefaultsUserScriptKey = "UserScripts"
    var userScripts: [UserScript]!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        navigationItem.rightBarButtonItem = UIBarButtonItem(barButtonSystemItem: .done, target: self, action: #selector(done))
        navigationItem.rightBarButtonItems = [
            UIBarButtonItem(barButtonSystemItem: .done, target: self, action: #selector(done)),
            UIBarButtonItem(barButtonSystemItem: .bookmarks, target: self, action: #selector(exampleJavascripts)),
            UIBarButtonItem(barButtonSystemItem: .compose, target: self, action: #selector(openSavedScripts))
        ]
        
        let notificationCenter = NotificationCenter.default
        notificationCenter.addObserver(self, selector: #selector(adjustForKeyboard), name: UIResponder.keyboardWillHideNotification, object: nil)
        notificationCenter.addObserver(self, selector: #selector(adjustForKeyboard), name: UIResponder.keyboardWillChangeFrameNotification, object: nil)
        
        
        if let inputItem = extensionContext?.inputItems.first as? NSExtensionItem,
             let itemProvider = inputItem.attachments?.first {
                itemProvider.loadItem(forTypeIdentifier: kUTTypePropertyList as String) {
                    [weak self] (dict, error) in
                    
                    guard let itemDictionary = dict as? NSDictionary else { return }
                    guard let javaScriptValues =
                        itemDictionary[NSExtensionJavaScriptPreprocessingResultsKey]
                            as? NSDictionary else { return }
                    print(javaScriptValues)
                    
                    self?.pageTitle = javaScriptValues["title"] as? String ?? ""
                    self?.pageURL = javaScriptValues["URL"] as? String ?? ""

                    DispatchQueue.main.async {
                        self?.title = self?.pageTitle
                        guard let actualPageUrl = self?.pageURL else { return }
                        guard let key = self?.userDefaultsUserScriptKey else { return }
                        let defaults = UserDefaults.standard
                        
                        if let savedScript = defaults.object(forKey: actualPageUrl) as? Data,
                            let savedUserScript = defaults.object(forKey: key) as? Data
                            {
                            let jsonDecoder = JSONDecoder()
                            do {
                                self?.script.text = try jsonDecoder.decode(String.self, from: savedScript)
                                self?.userScripts = try jsonDecoder.decode([UserScript].self, from: savedUserScript)
                             } catch {
                                 print("errrroooorr")
                             }
                         }
                    }
                }
            }
    }

    @IBAction func done() {

        saveUserDefaults(javascript: script.text,url: pageURL)
        
        let item = NSExtensionItem()
        let argument: NSDictionary = ["customJavaScript": script.text]
        let webDictionary: NSDictionary = [NSExtensionJavaScriptFinalizeArgumentKey: argument]
        let customJavaScript = NSItemProvider(item: webDictionary, typeIdentifier: kUTTypePropertyList as String)
        item.attachments = [customJavaScript]

        extensionContext?.completeRequest(returningItems: [item])
    }
    
    @objc func openSavedScripts(){
        
        let ac = UIAlertController(title: "Save Script", message: "Do you want to save this script?", preferredStyle: .alert)
        ac.addTextField()
        ac.addAction(UIAlertAction(title: "Ok", style: .default) {
            [weak self, weak ac] _ in
            guard let scriptName = ac?.textFields?[0].text else { return }
            guard let javascript = self?.script.text else { return }
            self?.saveUserDefaultUserScripts(scriptName: scriptName, script: javascript)
            if let vc = self?.storyboard?.instantiateViewController(withIdentifier: "UserScriptsTable") as? ScriptsTableViewController {
                vc.userScriptsDefaultsKey = self?.userDefaultsUserScriptKey
                vc.delegate = self
                self?.present(vc, animated: true)
            }
        })
        ac.addAction(UIAlertAction(title: "Cancel", style: .cancel))
        present(ac, animated: true)
        

        
    }
    
    func saveUserDefaultUserScripts(scriptName: String, script: String ){
                
        var finalUserScript = userScripts ?? [UserScript]()
        finalUserScript.append(UserScript(name: scriptName, script: script))
        
        let jsonEncoder = JSONEncoder()
        if let savedData = try? jsonEncoder.encode(finalUserScript) {
            let defaults = UserDefaults.standard
            defaults.set(savedData, forKey: userDefaultsUserScriptKey)
        } else {
            print("We failed to save the array")
        }
    }
    
    func saveUserDefaults(javascript: String, url: String ){
        
            let jsonEncoder = JSONEncoder()
            if let savedData = try? jsonEncoder.encode(javascript) {
                let defaults = UserDefaults.standard
                defaults.set(savedData, forKey: url)
            } else {
                print("We failed to save the array")
            }
    }

    @objc func exampleJavascripts(){
        let ac = UIAlertController(title: "JavaScript Example", message: "See the examples below:", preferredStyle: .actionSheet)
        ac.addAction(UIAlertAction(title: "Paul`s example", style: .default, handler: { [weak self](UIAlertAction) in
            self?.script.text = " alert(document.URL) "
        }))
        ac.addAction(UIAlertAction(title: "Leo Page Title", style: .default, handler: { [weak self](UIAlertAction) in
            self?.script.text = " alert(document.title) "
        }))
        present(ac,animated: true)
        
    }
    
    @objc func adjustForKeyboard(notification: Notification) {
        
        guard let keyboardValue = notification.userInfo?[UIResponder.keyboardFrameEndUserInfoKey] as? NSValue else { return}
        
        let keyboardScreenEndFrame = keyboardValue.cgRectValue
        let keyboardViewEndFrame = view.convert(keyboardScreenEndFrame, to: view.window)
        
        if notification.name == UIResponder.keyboardWillHideNotification {
            script.contentInset = .zero
        } else {
            script.contentInset = UIEdgeInsets(top: 0, left: 0, bottom: keyboardViewEndFrame.height - view.safeAreaInsets.bottom, right: 0)
        }
        
        script.scrollIndicatorInsets = script.contentInset
        
        let selectedRange = script.selectedRange
        script.scrollRangeToVisible(selectedRange)
        
    }
    
}
