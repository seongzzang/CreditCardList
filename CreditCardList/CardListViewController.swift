//
//  CardListViewController.swift
//  CreditCardList
//
//  Created by 양성혜 on 2022/09/02.
//

import UIKit
import Kingfisher
import FirebaseDatabase

class CardListViewController: UITableViewController {
    
    var ref: DatabaseReference!
    
    var creditCardList : [CreditCard] = []
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        let nibName = UINib(nibName: "CardListCell", bundle: nil)
        tableView.register(nibName, forCellReuseIdentifier: "CardListCell")
        
        ref = Database.database().reference()
        ref.observe(.value) {snapshot in
            guard let value = snapshot.value as? [String: [String:Any]] else { return }
            
            do {
                let jsonData = try JSONSerialization.data(withJSONObject: value)
                let cardData = try JSONDecoder().decode([String:CreditCard].self, from: jsonData)
                let cardList = Array(cardData.values)
                self.creditCardList = cardList.sorted {$0.rank < $1.rank}
                
                DispatchQueue.main.async {
                    self.tableView.reloadData()
                }
            } catch let error {
                print("ERROR JSON parsing \(error.localizedDescription)")
            }
        }
        
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return creditCardList.count
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: "CardListCell",for: indexPath) as? CardListCell else {return UITableViewCell()}
        
        cell.rankLabel.text = "\(creditCardList[indexPath.row].rank)위"
        cell.promotionLabel.text = "\(creditCardList[indexPath.row].promotionDetail.amount)만원 증정"
        cell.cardNameLabel.text = "\(creditCardList[indexPath.row].name)"
        
        let imageURL = URL(string: creditCardList[indexPath.row].cardImageURL)
        cell.cardImageView.kf.setImage(with: imageURL)
        
        return cell
    }
    
    override func tableView(_ tableView: UITableView, estimatedHeightForRowAt indexPath: IndexPath) -> CGFloat {
        return 200
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        //상세화면 전달
        let storyboard = UIStoryboard(name: "Main", bundle: Bundle.main)
        guard let detailViewController = storyboard.instantiateViewController(identifier: "CardDetailViewController") as? CardDetailViewController else { return }
        
        detailViewController.promotionDetail = creditCardList[indexPath.row].promotionDetail
        self.show(detailViewController,sender: nil)
    }
}
