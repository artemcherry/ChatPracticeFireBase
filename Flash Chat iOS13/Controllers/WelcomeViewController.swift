
import UIKit

class WelcomeViewController: UIViewController {
    
    @IBOutlet weak var titleLabel: UILabel!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Создаем анимацию появления текста в Label
        // Очищаем текст в lable
        titleLabel.text = ""
        // Creating text for appearing in Label
        let label = K.appName
        // Creating a loop for adding characters to label by time
        var second = 0.1
        for letter in label {
            Timer.scheduledTimer(withTimeInterval: second, repeats: false) { (timer) in
                self.titleLabel.text?.append(letter)
            }
            second += 0.1
        }
        
    }
    
    
}

