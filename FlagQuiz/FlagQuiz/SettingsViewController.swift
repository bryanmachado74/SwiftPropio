// SettingsViewController.swift
// Manages the app's settings
import UIKit

class SettingsViewController: UIViewController {
    @IBOutlet weak var guessesSegmentedControl: UISegmentedControl!
    @IBOutlet var switches: [UISwitch]!
    
    var model: Model! // set by QuizViewController
    private var regionNames = ["Africa", "Asia", "Europe",
                                  "North_America", "Oceania", "South_America"]
    private let defaultRegionIndex = 3
    
    // used to determine whether any settings changed
    private var settingsChanged = false

    // called when SettingsViewController is displayed
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // select segment based on current number of guesses to display
        guessesSegmentedControl.selectedSegmentIndex =
        model.numberOfGuesses / 2 - 1
        
        // set switches based on currently selected regions
        for i in 0 ..< switches.count {
            switches[i].isOn = model.regions[regionNames[i]]!
            }
        }
    /*
    // update guesses based on selected segment's index
    @IBAction func numberOfGuessesChanged(sender: UISegmentedControl) {
        model.setNumberOfGuesses(guesses: 2 + sender.selectedSegmentIndex * 2)
        settingsChanged = true
    }
    */
    // toggle region corresponding to toggled UISwitch
    @IBAction func switchChanged(sender: UISwitch) {
        for i in 0 ..< switches.count {
            if sender === switches[i] {
                model.toggleRegion(name: regionNames[i])
                settingsChanged = true
            }
        }//end for
        
        // if no switches on, default to North America and display error
        
/*        if model.regions.values.filter(true, throw $0).array.count == 0 {
            model.toggleRegion(name: regionNames[defaultRegionIndex])
            switches[defaultRegionIndex].isOn = true
            displayErrorDialog()
        }//end if
 */
    }//end switchChanged()
    
    // display message that at least one region must be selected
    func displayErrorDialog() {
        // create UIAlertController for user input
        let alertController = UIAlertController(
            title: "At Least One Region Required",
            message: String(format: "Selecting %@ as the default region.",
            regionNames[defaultRegionIndex]),
            preferredStyle: UIAlertControllerStyle.alert)
        
        let okAction = UIAlertAction(title: "OK",
                                     style: UIAlertActionStyle.cancel, handler: nil)
        alertController.addAction(okAction)
        
        present(alertController, animated: true,
                                 completion: nil)
        }

    // called when user returns to quiz
    override func viewWillDisappear(_ animated: Bool) {
        if settingsChanged {
            model.notifyDelegate() // called only if settings changed
            }
        }
}
