//
//  DetailsViewController.swift
//  ArtBookProject
//
//  Created by Amrah on 05.06.24.
//

import UIKit
import CoreData

class DetailsViewController: UIViewController, UINavigationControllerDelegate, UIImagePickerControllerDelegate {

    @IBOutlet weak var imageView: UIImageView!
    @IBOutlet weak var nameText: UITextField!
    @IBOutlet weak var authorText: UITextField!
    @IBOutlet weak var yearText: UITextField!
    @IBOutlet weak var saveButton: UIButton!
    //Biz bunu ona gore duzeldirik ki, + icon a klik edende form acilsin amma liste klik edende sekil cixsin. Same screens but different
    var chosenPainting = ""
    var chosenPaintingID: UUID?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        if(chosenPainting != ""){
            saveButton.isEnabled = false
            //Core Data
            let appDelegate = UIApplication.shared.delegate as! AppDelegate
            let context = appDelegate.persistentContainer.viewContext
            
            //Datanı götürmək
            let fetchRequest = NSFetchRequest<NSFetchRequestResult>(entityName: "Paintings")
            
            //Filtirlemek uchun, yeni sadece bize lazim olan listi cixartmaq.
            let idString = chosenPaintingID?.uuidString
            //Burda ise demek istediyimiz id-si idString-e beraber olan-i mene goster
            fetchRequest.predicate = NSPredicate(format: "id = %@", idString!)
            
            fetchRequest.returnsObjectsAsFaults = false
            
            do {
               let results = try context.fetch(fetchRequest)
                
                if results.count > 0 {
                    for result in results as! [NSManagedObject]{
                        if let name = result.value(forKey: "name") as? String{
                            nameText.text = name
                        }
                        if let artist = result.value(forKey: "painter") as? String{
                            authorText.text = artist
                        }
                        if let year = result.value(forKey: "year") as? Int {
                            yearText.text = String(year)
                        }
                        
                        if let imageData = result.value(forKey: "image") as? Data {
                            let image = UIImage(data: imageData)
                            imageView.image = image
                        }
                    }
                }
            } catch {
                print("Error")
            }
            
        } else {
            saveButton.isEnabled = false
            nameText.text = "Painting Name"
            authorText.text = "Pablo Picasso"
            yearText.text = "1875"
        }
        
        
        
        //RECOGNIZERS
        let gestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(hideKeyboardFunc))
        view.addGestureRecognizer(gestureRecognizer)
        
        imageView.isUserInteractionEnabled = true
        let imageTapRecognizer = UITapGestureRecognizer(target: self, action: #selector(selectImage))
        imageView.addGestureRecognizer(imageTapRecognizer)

    }
    
    @objc func selectImage(){
        let picker = UIImagePickerController()
        picker.delegate = self
        picker.sourceType = .photoLibrary
        picker.allowsEditing = true
        present(picker, animated: true, completion: nil)
    }
    
     func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        imageView.image = info[.originalImage] as? UIImage
         saveButton.isEnabled = true
        self.dismiss(animated: true, completion: nil)
        
    }
    
    @objc func hideKeyboardFunc(){
        view.endEditing(true)
    }
    @IBAction func saveButtonClicked(_ sender: Any) {
        let appDelegate = UIApplication.shared.delegate as? AppDelegate
        let context = appDelegate?.persistentContainer.viewContext
        
        let newPainting = NSEntityDescription.insertNewObject(forEntityName: "Paintings", into: context!)

        newPainting.setValue(nameText.text!, forKey: "name")
        newPainting.setValue(authorText.text!, forKey: "painter")
        
        if let year = Int(yearText.text!){
            newPainting.setValue(year, forKey: "year")
        }
        newPainting.setValue(UUID(), forKey: "id")
        let data = imageView.image?.jpegData(compressionQuality: 0.5)
        newPainting.setValue(data, forKey: "image")
        
        do {
            try context?.save()
            print("Success")
        } catch {
            print("Error")
        }
        
        //Notification Center nə edir - Dusun ki bu action bas verir ve butun screenlere bu mesaj gəlir. Və biz bununla digər screenlərdə newData adli bildiris gelibse ona uygun olaraq da actionlar ede bilerik
        NotificationCenter.default.post(name: NSNotification.Name("newData"), object: nil)
        self.navigationController?.popViewController(animated: true)
    }
    
    
    
}
