//
//  ViewController.swift
//  Project7
//
//  Created by Андрей Бородкин on 01.07.2021.
//

import UIKit


//MARK: - Extensions

//Table View setup
extension ViewController {
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        petitions.count
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "Cell", for: indexPath)
        
        let petitions = petitions[indexPath.row]
       
        
        if #available(iOS 14, *) {
            var configuration = cell.defaultContentConfiguration()
            configuration.text = petitions.title
            configuration.secondaryText = petitions.body
            cell.contentConfiguration = configuration
        } else {
            cell.textLabel?.text = petitions.title
            cell.detailTextLabel?.text = petitions.body
        }
        
        
        return cell
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let vc = DetailViewController()
        vc.detailItem = petitions[indexPath.row]
        navigationController?.pushViewController(vc, animated: true)
    }
    
}

// Data handling
extension ViewController {
    
    func parse(json: Data){
        let decoder = JSONDecoder()
        
        if let jsonPetitions = try? decoder.decode(Petitions.self, from: json) {
            petitions = jsonPetitions.results
            
            DispatchQueue.main.async { [weak self] in
                self?.tableView.reloadData()
            }
            
        }
    }
    
    
    fileprivate func reloadData() {
        let urlString: String
        if navigationController?.tabBarItem.tag == 0 {
            urlString = "https://hackingwithswift.com/samples/petitions-1.json"
            //urlString = "https://api.whitehouse.gov/v1/petitions.json?limit=100"
        } else {
            urlString = "https://hackingwithswift.com/samples/petitions-2.json"
        }
        
        //let urlString = "https://api.whitehouse.gov/v1/petitions.json?limit=100"
        
        DispatchQueue.global(qos: .userInitiated).async { [weak self] in
            if let url = URL(string: urlString) {
                if let data = try? Data(contentsOf: url) {
                    // we're ok to parse
                    self?.parse(json: data)
                    return
                }
            }
            self?.showError()
        }
        
        
    }
}


//MARK: - ViewController
class ViewController: UITableViewController {
    
    var petitions = [Petition]()
    var petitionsFiltered = [Petition]()

    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        reloadData()
        
        navigationItem.rightBarButtonItem = UIBarButtonItem(title: "Credits", style: .plain, target: self, action: #selector(showCredits))
        
        navigationItem.leftBarButtonItem = UIBarButtonItem(barButtonSystemItem: .search, target: self, action: #selector(filterResults))
        
    }

    func showError() {
        
        DispatchQueue.main.async { [weak self] in
            let ac = UIAlertController(title: "Loading Error", message: "There was a problem loading the feed. Ploease check your internet connection", preferredStyle: .alert)
            ac.addAction(UIAlertAction(title: "OK", style: .default, handler: nil))
            self?.present(ac, animated: true, completion: nil)
        }
    }
    
  
    //MARK: - NavItems Methods
    @objc func showCredits() {
        let ac = UIAlertController(title: "Credits", message: "This data is provided by Paul Hudson", preferredStyle: .alert)
        ac.addAction(UIAlertAction(title: "Dissmiss", style: .default, handler: nil))
        present(ac, animated: true, completion: nil)
    }
    
    @objc func filterResults() {
        let ac = UIAlertController(title: "Filter", message: "Enter search word", preferredStyle: .alert)
        ac.addTextField() { textfield in
            textfield.placeholder = "Enter keyword"
        }
        
        let searchAction =  UIAlertAction(title: "Search", style: .default) { _ in
            guard let searchWord = ac.textFields?[0].text else {return}
            self.reloadData()
            self.petitions = self.petitions.filter { petition  in
                petition.body.contains(searchWord)
            }
            print(self.petitionsFiltered)
            self.tableView.reloadData()
        }
        ac.addAction(searchAction)
        
        let reloadAction = UIAlertAction(title: "Reload initial data", style: .cancel) { _ in
            self.reloadData()
        }
        
        ac.addAction(reloadAction)
           
        present(ac, animated: true, completion: nil)
        
    }
    
}

