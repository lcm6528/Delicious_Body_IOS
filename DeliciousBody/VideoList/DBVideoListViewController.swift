//
//  DBVideoListViewController.swift
//  DeliciousBody
//
//  Created by changmin lee on 2018. 5. 1..
//  Copyright © 2018년 changmin. All rights reserved.
//

import UIKit

class DBVideoListViewController: UIViewController {
    var tableViewModel = VideoViewModel()
    
    @IBOutlet var tableViewAll: UITableView!
    @IBOutlet var tableViewLike: UITableView!
    @IBOutlet weak var scrollView: UIScrollView!
    
    @IBOutlet weak var tabbarView: UIView!
    @IBOutlet weak var allButton: UIButton!
    @IBOutlet weak var likeButton: UIButton!
    var tabbarLine = UIView()
    
    let kTabbarPadding: CGFloat = 23
    let kTabbarLineHeight: CGFloat = 2
    
    var option: Int = 0 {
        didSet {
            allButton.isSelected = option == 0
            likeButton.isSelected = option == 1
            animate()
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.navigationController?.delegate = self
        setupTableView()
        setupUI()
    }
    
    func setupTableView(){
        tableViewAll.register(UINib(nibName: "DBExerCell", bundle: nil) , forCellReuseIdentifier: "exerCell")
        tableViewLike.register(UINib(nibName: "DBExerCell", bundle: nil) , forCellReuseIdentifier: "exerCell")
        tableViewAll.delegate = tableViewModel
        tableViewAll.dataSource = tableViewModel
        tableViewLike.delegate = tableViewModel
        tableViewLike.dataSource = tableViewModel
        
        tableViewModel.handler = { exercise in
            let storyBoard = UIStoryboard(name: "Home", bundle: nil)
            let mainViewController = storyBoard.instantiateViewController(withIdentifier: "DBVideoViewController") as! DBVideoViewController
            mainViewController.exercise = exercise
            self.present(mainViewController, animated: true, completion: nil)
        }
    }
    
    func setupUI() {
        tabbarLine.frame = CGRect(x: kTabbarPadding, y: 50 - kTabbarLineHeight, width: SCREEN_WIDTH / 2 - kTabbarPadding, height: kTabbarLineHeight)
        tabbarLine.backgroundColor = UIColor.themeBlue
        tabbarLine.layer.cornerRadius = 1
        tabbarLine.clipsToBounds = true
        
        tabbarView.addSubview(tabbarLine)
    }
    
    @IBAction func searchButtonPressed(_ sender: Any) {
        performSegue(withIdentifier: "search", sender: nil)
    }
    @IBAction func acitoin(_ sender: UIButton) {
        guard sender.tag != option else {
            return
        }
        option = sender.tag
    }
    
    func animate() {
        let sender: UIButton = option == 0 ? allButton : likeButton
        UIView.animate(withDuration: 0.4, delay: 0, usingSpringWithDamping: 0.8, initialSpringVelocity: 0, options: .curveLinear, animations: {
            self.scrollView.contentOffset.x = SCREEN_WIDTH * CGFloat(self.option)
            self.tabbarLine.center.x = self.option == 0 ? self.allButton.center.x : self.likeButton.center.x
            
        })
        UIView.animate(withDuration: 0.1, delay: 0.0, options: .curveEaseOut, animations: {
            sender.transform = CGAffineTransform(scaleX: 0.8, y: 0.8)
        }) { (complete) in
            UIView.animate(withDuration: 0.1, delay: 0.0, options: .curveEaseOut, animations: {
                sender.transform = CGAffineTransform(scaleX: 1.15, y: 1.15)
            }) { (complete) in
                UIView.animate(withDuration: 0.1, delay: 0.0, options: .curveEaseIn, animations: {
                    sender.transform = CGAffineTransform(scaleX: 0.95, y: 0.95)
                }) { (complete) in
                    UIView.animate(withDuration: 0.1, delay: 0.0, options: .curveEaseIn, animations: {
                        sender.transform = CGAffineTransform.identity
                    }) { (complete) in
                        
                    }
                }
            }
        }
    }
}

extension DBVideoListViewController: UIScrollViewDelegate {
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        print(scrollView.contentOffset.x)
        let ratio = scrollView.contentOffset.x / SCREEN_WIDTH
        tabbarLine.center.x = allButton.center.x  + (likeButton.center.x - allButton.center.x) * ratio
    }
    
    func scrollViewDidEndDecelerating(_ scrollView: UIScrollView) {
        option = Int(round(scrollView.contentOffset.x / SCREEN_WIDTH))
    }
}

extension DBVideoListViewController: UINavigationControllerDelegate {
    func navigationController(_ navigationController: UINavigationController, animationControllerFor operation: UINavigationControllerOperation, from fromVC: UIViewController, to toVC: UIViewController) -> UIViewControllerAnimatedTransitioning? {
        
        guard toVC is DBVideoSearchViewController || fromVC is DBVideoSearchViewController else {
            return nil
        }
        var originFrame = tabbarLine.frame
        originFrame.origin.y += 64
        switch operation {
        case .push:
            return DBVideoSearchTransition(isPresenting: true, originFrame: originFrame)
        default:
            return DBVideoSearchTransition(isPresenting: false, originFrame: originFrame)
        }
    }
}
