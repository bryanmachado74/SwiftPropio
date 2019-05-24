// QuizViewController.swift
// Manages the quiz
import UIKit

class QuizViewController: UIViewController, ModelDelegate {
    @IBOutlet weak var flagImageView: UIImageView!
    @IBOutlet weak var questionNumberLabel: UILabel!
    @IBOutlet var segmentedControls: [UISegmentedControl]!
    @IBOutlet weak var answerLabel: UILabel!
    
    private var model: Model! // reference to the model object
    private let correctColor = UIColor.green
    private let incorrectColor = UIColor.red
    private var quizCountries: [String]! = nil // array con el filename de las banderas
    private var enabledCountries: [String]! = nil //array con filenames de todos los paises disponibles (nombres)
    private var correctAnswer: String! = nil //respuesta de la pregunta actual
    private var correctGuesses = 0
    private var totalGuesses = 0

    // obtains the app
    override func viewDidLoad() {
        super.viewDidLoad()
        model = Model(delegate: self)// create Model
        settingsChanged()
    }//end viewLoad
    
    // SettingsDelegate: reconfigures quiz when user changes settings. Also called when app first loads
    func settingsChanged() {
        enabledCountries = model.enabledRegionCountries
        resetQuiz()
    }//end settingsChanged
    
    // start a new quiz
    func resetQuiz() {
        quizCountries = model.newQuizCountries() // countries in new quiz
        correctGuesses = 0
        totalGuesses = 0
        // display appropriate # of UISegmentedControls
        for i in 0 ..< segmentedControls.count {
            segmentedControls[i].isHidden = (i < model.numberOfGuesses / 2) ? false : true//ERR segmentedControls[i].hidden =
        }//end for
        nextQuestion() // display the first flag in quiz
    }//end reset quiz

    // displays next question
    func nextQuestion() {
        questionNumberLabel.text = String(format: "Question %1$d of %2$d", (correctGuesses + 1), model.numberOfQuestions)
        answerLabel.text = ""
        correctAnswer = quizCountries.removeFirst() //ERR correctAnswer = quizCountries.removeAtIndex(0)
        flagImageView.image = UIImage(named: correctAnswer) //next flag
        // re-enable UISegmentedControls and delete prior segments
        for segmentedControl in segmentedControls {
            segmentedControl.isEnabled = true //ERR segmentedControl.enabled
            segmentedControl.removeAllSegments()
        }//end for
        
        // place guesses on displayed UISegmentedControls
        enabledCountries.shuffle() // use Array extension method
        var i = 0
        for segmentedControl in segmentedControls {
            if !segmentedControl.isHidden { //ERR if !segmentedControl.hidden {
                var segmentIndex = 0
                while segmentIndex < 2 { // 2 per UISegmentedControl
                    if i < enabledCountries.count && correctAnswer != enabledCountries[i] {
                        segmentedControl.insertSegment(withTitle: countryFromFilename(filename: enabledCountries[i]), at: segmentIndex, animated:false)
                        segmentIndex = segmentIndex+1 //++segmentIndex
                    }//end if
                    i=i+1 //ERR ++i
                }//end while
            }//end if
        }//end for

        // pick random segment and replace with correct answer
        let randomRow = Int(arc4random_uniform(UInt32(model.numberOfGuesses / 2)))
        let randomIndexInRow = Int(arc4random_uniform(UInt32(2)))
        segmentedControls[randomRow].removeSegment(at: randomIndexInRow, animated: false)
        segmentedControls[randomRow].insertSegment(withTitle: countryFromFilename(filename: correctAnswer), at: randomIndexInRow, animated: false)
    }//nextQuestion()

    // converts image filename to displayable guess String
    func countryFromFilename(filename: String) -> String {
        var name = filename.components(separatedBy : "-")[1]
        let length: Int = name.count //countElements(name)
        name = (name as NSString).substring(to: length - 4)
        let components = name.components(separatedBy:"_")
        return components.joined(separator: " ")//join(" ", components)
    }//end countryFromFilename
    
    // called when the user makes a guess
    @IBAction func submitGuess(sender: UISegmentedControl) {
       // get the title of the bar at that segment, which is the guess
        let guess = sender.titleForSegment(at: sender.selectedSegmentIndex)!
        let correct = countryFromFilename(filename: correctAnswer)
        totalGuesses = totalGuesses + 1 //++totalGuesses
        if guess != correct { // incorrect guess
            // disable incorrect guess
            sender.setEnabled(false, forSegmentAt: sender.selectedSegmentIndex)
            answerLabel.textColor = incorrectColor
            answerLabel.text = "Incorrect"
            answerLabel.alpha = 1.0
            UIView.animate(withDuration: 1.0, animations: {self.answerLabel.alpha = 0.0})
            shakeFlag()
        } else { // correct guess
            answerLabel.textColor = correctColor
            answerLabel.text = guess + "!"
            answerLabel.alpha = 1.0
            correctGuesses = correctGuesses+1 //++correctGuesses
            // disable segmentedControls
            for segmentedControl in segmentedControls {
                segmentedControl.isEnabled = false
            }//end for
            if correctGuesses == model.numberOfQuestions { // quiz over
                displayQuizResults()
            } else { // use GCD to load next flag after 2 seconds
                let mainQueue = DispatchQueue.main
                let deadline = DispatchTime.now() + .seconds(2)
                mainQueue.asyncAfter(deadline: deadline) { self.nextQuestion() }
            }//end else
        }//end else
    }// end submitGuess()

    // shakes the flag to visually indicate incorrect response
    func shakeFlag() {
        UIView.animate(withDuration: 0.1, animations: {self.flagImageView.frame.origin.x += 16})
        UIView.animate(withDuration: 0.1, delay: 0.1, options: [], animations: {self.flagImageView.frame.origin.x -= 32}, completion: nil)
        UIView.animate(withDuration: 0.1, delay: 0.2, options: [], animations: {self.flagImageView.frame.origin.x += 32}, completion: nil)
        UIView.animate(withDuration: 0.1, delay: 0.3, options: [], animations: {self.flagImageView.frame.origin.x -= 32}, completion: nil)
        UIView.animate(withDuration: 0.1, delay: 0.4, options: [], animations: {self.flagImageView.frame.origin.x += 16}, completion: nil)
    }//end shakeFlag()

    // displays quiz results
    func displayQuizResults() {
        let result:Double = (Double(correctGuesses / totalGuesses))
        let percentString = NumberFormatter.localizedString(from: NSNumber(value: result), number: NumberFormatter.Style.percent)
        // create UIAlertController for user input
        let alertController = UIAlertController(title: "Quiz Results", message: String(format: "%1$i guesses, %2$@ correct", totalGuesses, percentString), preferredStyle: UIAlertControllerStyle.alert)
        let newQuizAction = UIAlertAction(title: "New Quiz", style: UIAlertActionStyle.default, handler: {(action) in self.resetQuiz()})
        alertController.addAction(newQuizAction)
        present(alertController, animated: true, completion: nil)
    }//end displaysQuizResults

    // called before seque from MainViewController to DetailViewController
    func pprepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
            if segue.identifier == "showSettings" {
                let controller = segue.destination as! SettingsViewController
                controller.model = model
            }// end if
    }//end prepareForSegue
    
}//end class

// Array extension method for shuffling elements
extension Array {
    mutating func shuffle() {
        // Modern Fisher-Yates shuffle: http://bit.ly/FisherYates
        for first in stride(from: self.count - 1, through: 1, by: -1) {
                let second = Int(arc4random_uniform(UInt32(first + 1)))
                self.swapAt(first, second)
        }//end for
    }//end shuffle()
}//end Array{}







