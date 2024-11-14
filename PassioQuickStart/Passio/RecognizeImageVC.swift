//
//  RecognizeImageVC.swift
//  PassioQuickStart
//
//  Created by Pratik on 21/10/24.
//

import UIKit
import PassioNutritionAISDK

class RecognizeImageVC: UIViewController {

    @IBOutlet weak var selectedImageView: UIImageView!
    @IBOutlet weak var loadingView: UIView!
    @IBOutlet weak var foodListTable: UITableView!

    var selectedImage: UIImage?
    var foodInfo: [PassioAdvisorFoodInfo] = []
    
    override func viewDidLoad() {
        super.viewDidLoad()
        basicSetup()
        fetchData()
    }
    
    func basicSetup() {
        loadingView.layer.cornerRadius = 6
        selectedImageView.layer.cornerRadius = 8
        foodListTable.registerNib(FoodListCell.self)
        
        // Set food image
        guard let image = selectedImage else { return }
        selectedImageView.image = image
    }
    
    func updateLoader(show: Bool) {
        loadingView.isHidden = !show
    }
    
    func fetchData() {
        guard let image = selectedImage else { return }
        updateLoader(show: true)
        PassioNutritionAI.shared.recognizeImageRemote(image: image) { passioAdvisorFoodInfo in
            DispatchQueue.main.async {
                self.updateLoader(show: false)
                self.didFetch(foods: passioAdvisorFoodInfo)
            }
        }
    }
    
    func didFetch(foods: [PassioAdvisorFoodInfo]) {
        if foods.count < 1 {
            showAlert()
            return
        }
        foodInfo = foods
        foodListTable.reloadData()
    }
    
    func showAlert() {
        let alert = UIAlertController(title: "Unable to recognize food", message: nil, preferredStyle: .alert)
        let defaultAction = UIAlertAction(title: "Ok", style: .default, handler: { action in
            self.navigationController?.popViewController(animated: true)
        })
        alert.addAction(defaultAction)
        DispatchQueue.main.async(execute: {
            self.present(alert, animated: true)
        })
    }
}

extension RecognizeImageVC: UITableViewDelegate, UITableViewDataSource {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return foodInfo.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeue(FoodListCell.self, for: indexPath)
        let food = foodInfo[indexPath.row]
        cell.configure(food: food)
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let food = foodInfo[indexPath.row]
        let storyBoard = UIStoryboard(name: "Main", bundle: nil)
        let foodDetailVC = storyBoard.instantiateViewController(withIdentifier: "FoodDetailVC") as! FoodDetailVC
        foodDetailVC.food = food
        self.navigationController?.pushViewController(foodDetailVC, animated: true)
    }
}
