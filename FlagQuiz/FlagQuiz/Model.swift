//  Model.swift
import Foundation

protocol ModelDelegate {
    func settingsChanged()
}//end ModelDelegate()

class Model {
    // keys for storing data in the app's NSUserDefaults [El Modelo los usa para almacenar y recuperar las config en NSUserDefaults]
    private let regionsKey = "FlagQuizKeyRegions"
    private let guessesKey = "FlagQuizKeyGuesses"
    
    // reference to QuizViewController to notify it when settings change //implicitamente desaprovechado opcional.
    //El modelo usa esta propiedad para notificar la QuizViewController para empezar un nuevo quiz cuando las configuraciones cambian.
    private var delegate: ModelDelegate! = nil
    
    var numberOfGuesses = 4 // number of guesses to display
    private var enabledRegions = ["Africa" : false, "Asia" : false, "Europe" : false, "NorthAmerica" : true, "Oceania" : false, "SouthAmerica" : false]
    
    // variables for maintaining quiz data
    let numberOfQuestions = 10
    private var allCountries: [String] = []
    private var countriesInEnabledRegions: [String] = []
    
    init(delegate: ModelDelegate) {// initialize the Settings from the app's NSUserDefaults
        self.delegate = delegate
        
        //get the NSUserDefaults object for the app
        let userDefaults = UserDefaults.standard //Replace 'NSUserDefaults' with 'UserDefaults' //creamos una constante singleton de userDefaults para acceder a las imagenes
        // get number of guesses
        let tempGuesses = userDefaults.integer(forKey: guessesKey) //la cantidad de respuestas
        if tempGuesses != 0 {
            numberOfGuesses = tempGuesses
        }
        
        // get Dictionary containing the region settings
        if let tempRegions = userDefaults.dictionary(forKey: regionsKey) {
            self.enabledRegions = tempRegions as! [String : Bool]
        }

        // get a list of all the png files in the app's images group
        let paths = Bundle.main.paths(forResourcesOfType: "png", inDirectory: nil) as [String]

        // get image filenames from paths
        for path in paths {
            if !path.hasPrefix("AppIcon") {//if !path.lastPathComponent.hasPrefix("AppIcon") {
                allCountries.append(String(path.last!))
            }//end if
        }//end for

        regionsChanged() //populate countriesInEnabledRegions
    }//end init
    
    //loads countriesInEnabledRegions
    func regionsChanged() {
        countriesInEnabledRegions.removeAll()
        for filename in allCountries {
            let region = filename.components(separatedBy: "-")[0]
            if enabledRegions[region]! {
                countriesInEnabledRegions.append(filename)
            }//end if
        }//end for
    }//end regionsChanged()
    
    var regions: [String : Bool] {return enabledRegions}// returns Dictionary indicating the regions to include in the quiz
    var enabledRegionCountries: [String] {return countriesInEnabledRegions}// returns Array of countries for only the enabled regions
    
    // toggles a region on or off
    func toggleRegion(name: String) {
        enabledRegions[name] = !(enabledRegions[name]!)
        UserDefaults.standard.set(enabledRegions as NSDictionary, forKey: regionsKey)
        UserDefaults.standard.synchronize()
        regionsChanged() // populate countriesInEnabledRegions
    }//end toggleRegion()
    
/*    // changes the number of guesses displayed with each flag
    func setNumberOfGuesses(guesses: Int) {
        numberOfGuesses = guesses.setInteger(numberOfGuesses, forKey: guessesKey);
        UserDefaults.standard.synchronize()
    }//setNumberOfGuesses()
*/
    // called by SettingsViewController when settings change. To have model notify QuizViewController of the changes
    func notifyDelegate() {
        delegate.settingsChanged()
    }//end notifyDelegate()
    
    // return Array of flags to quiz based on enabled regions
    func newQuizCountries() -> [String] {
        var quizCountries: [String] = []
        var flagCounter = 0
        
        // add 10 random filenames to quizCountries
        while flagCounter < numberOfQuestions {
            let randomIndex = Int(arc4random_uniform(UInt32(Int32(enabledRegionCountries.count))))
            let filename = enabledRegionCountries[randomIndex]// if image's filename is not in quizCountries, add it
            if quizCountries.filter({$0 == filename}).count == 0 {
                quizCountries.append(filename)
                flagCounter=flagCounter+1 //Unary operator '++' cannot be applied to an operand of type '@lvalue Int'
            }//if
        }//while
        return quizCountries
    }//end newQuizCountries()
}//end Class
