import UIKit

class MainViewController: UIViewController {

    @IBOutlet weak var mainTableView: UITableView!
    
    fileprivate var dataSource: NotesDataSource!
    var stateController: StateController!
    var note: Note!
  
    override func viewDidLoad() {
        super.viewDidLoad()
            
        // Setup TableView
        mainTableView.delegate = self
        mainTableView.estimatedRowHeight = UITableViewAutomaticDimension
        mainTableView.rowHeight = UITableViewAutomaticDimension
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(true)
        
        //Load data from the datasource, then store into tableview data
        dataSource = NotesDataSource(notes: stateController.notes)
        mainTableView.dataSource = dataSource
        mainTableView.reloadData()
    }
    
    @IBAction func createNewNote(_ sender: Any) {
        // Popup alert for creating a new note
        let alert = UIAlertController(title: "", message: "", preferredStyle: .alert)
        
        let saveAction = UIAlertAction(title: "Save", style: .default, handler: {(action:UIAlertAction) -> Void in
            let textField = alert.textFields!.first
            guard !(textField?.text == "") else { return }
            
            let dateCreated = Date()
            self.note = Note(noteName: textField!.text!, chords: [], dateCreated: dateCreated)
            //self.dataSource.notes.append(self.note)
            self.stateController.add(self.note)
            
            self.performSegue(withIdentifier: "NewNoteSegue", sender: nil)
        })
        
        let cancelAction = UIAlertAction(title: "Cancel", style: .default) { (action: UIAlertAction) -> Void in }
        
        alert.addTextField(configurationHandler: {(textField: UITextField) in
            textField.addTarget(self, action: #selector(self.textFieldDidChange), for: .editingChanged)
        })
 
        let attributedString = NSAttributedString(string: "New Note", attributes: [
            NSAttributedStringKey.foregroundColor : UIColor.themeColor()
            ])
        alert.setValue(attributedString, forKey: "attributedTitle")
        
        alert.view.layer.cornerRadius = 60
        alert.view.tintColor = UIColor.themeColor()
        alert.addAction(saveAction)
        alert.addAction(cancelAction)
        
        present(alert, animated: true, completion: nil)
    }
    
    // Disables Save button in the create new note alert window if title is blank
    @objc func textFieldDidChange(sender: AnyObject) {
        let tf = sender as! UITextField
        var resp: UIResponder = tf
        while !(resp is UIAlertController) {
            resp = resp.next!
        }
        let alert = resp as! UIAlertController
        (alert.actions[1] as UIAlertAction).isEnabled = (tf.text != "")
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        switch segue.identifier! {
        case "NewNoteSegue":
            if let chordsVC = segue.destination as? ChordsViewController {
                let newNote = self.note
                chordsVC.note = newNote
                chordsVC.stateController = stateController
            }
        case "ViewNoteSegue":
            if let chordsVC = segue.destination as? ChordsViewController,
                let selectedIndex = mainTableView.indexPathForSelectedRow {
                let note = dataSource.notes[selectedIndex.row]
                chordsVC.note = note
                chordsVC.stateController = stateController
            } else {
                print("Unable to get destination or index path")
            }
        default:
            print("No matching segue")
            break
        }
    }
}

//MARK: - TableView Delegate and DataSource

extension MainViewController: UITableViewDelegate {
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 150
    }
        
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        performSegue(withIdentifier: "ViewNoteSegue", sender: nil)
        mainTableView.deselectRow(at: indexPath, animated: true)
    }
    
    func tableView(_ tableView: UITableView, didEndEditingRowAt indexPath: IndexPath?) {
        if let indexPath = indexPath {
            stateController.deleteNote(at: indexPath.row)
        } else {
            print("indexPath is nil")
        }
    }
}
