//
//  PreferenceViewController.swift
//  HiddenPokemonSearcher
//

import UIKit

class PreferenceViewController: UIViewController {

    // MARK: - Internal
    @IBOutlet weak var radiusLabel: UILabel!
    @IBOutlet weak var radiusTextField: UITextField!
    
    // MARK: - ViewController Override
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        initEachViewItem()
    }

    override func viewDidDisappear(_ animated: Bool) {
        AppPreference.SaveAllParameters()
        
        super.viewDidDisappear(animated)
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    
    // MARK: - ViewController Action
    /**
     [Action]cancelButton Event:TouchDown
     */
    @IBAction func cancelButtonTap(_ sender: UIBarButtonItem) {
        _ = self.navigationController?.popViewController(animated: true)
    }
    
    /**
     [Action]saveButton Event:TouchDown
     */
    @IBAction func saveButtonTap(_ sender: UIBarButtonItem) {
        
        // Check the validity of the parameters.
        let result = checkingEachParameter()
        if (result != true) {
            
            let alertController: UIAlertController = UIAlertController(title: "Alert", message: NSLocalizedString("MSG_RADIUS_LIMIT_ERROR", comment: ""), preferredStyle: .alert)
            let actionOK = UIAlertAction(title: "OK", style: .default){
                (action) -> Void in
            }
            alertController.addAction(actionOK)
            present(alertController, animated: true, completion: nil)
            
            return
        }
        
        // Saving all parameter.
        saveEachParameter()
        
        // Back the main view.
        _ = self.navigationController?.popViewController(animated: true)
    }
    
    // MARK: - private method
    /**
     Initialization of each item.
     */
    func initEachViewItem() {
        
        // Navi bar
        self.navigationItem.title = NSLocalizedString("TITLE_SETTINGS", comment: "")
        
        // Parameter area
        radiusLabel.text = NSLocalizedString("MSG_LABEL_NEARBY_RADIUS", comment: "")
        radiusTextField.text = String(AppPreference.GetHiddenRadius())
    }
    
    /**
     Checking each parameter.
     - returns: True:OK False:NG.
     */
    func checkingEachParameter() -> Bool {
        
        let radius: Int32? = Int32(radiusTextField.text!)
        if (radius != nil) && (radius! > 0 && radius! <= 400) {
            // Check result is OK.
        }
        else {  // NG
            return false
        }
        
       return true
    }
    
    /**
     Savinging all parameter.
     - returns: True:OK False:NG.
     */
    private func saveEachParameter() {
        
        // Setting each parameter.
        AppPreference.SetHiddenRadius(value: Int32(radiusTextField.text!)!)
        
        // Execute saving.
        AppPreference.SaveAllParameters()
    }
    

}
