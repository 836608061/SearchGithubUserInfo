//
//  SearchUserInfoViewController.swift
//  SearchGithubUserInfo
//
//  Created by menhao on 17/5/15.
//  Copyright © 2017年 menhao. All rights reserved.
//

import UIKit

class SearchUserInfoViewController: UIViewController,UITableViewDelegate,UITableViewDataSource,UITextFieldDelegate{
    //MARK: - property
    private let ID = "withIdentifier"
    var searchUsNameModel : SearchUserNameModel? = nil
    var searchFavirLagModel : SearchFavirLagModel? = nil
    var searchResultArray = [SearchUserNameModel]()
    var searchLangArray = [SearchFavirLagModel]()
    var tabView : UITableView?
    var searchUsNameIsFinished = false
    var searchFirLangIsFinished = false
      //MARK: - life cycle
    override func viewDidLoad() {
        super.viewDidLoad()
        self.setUpUI()
        self.reloadData()
    }

    
  private  func setUpUI(){
     self.view.backgroundColor = UIColor.white
        // 背景图片
     let bgImageV = UIImageView(frame: self.view.bounds)
     self.view.addSubview(bgImageV)
     bgImageV.isUserInteractionEnabled = true
        //输入框
        let useInfoTextField = UITextField()
        self.view.addSubview(useInfoTextField)
        useInfoTextField.layer.borderWidth = 0.5
        useInfoTextField.layer.backgroundColor = UIColor.white.cgColor
        useInfoTextField.layer.cornerRadius = 10.0
        useInfoTextField.layer.masksToBounds = true
        useInfoTextField.delegate = self
        useInfoTextField.keyboardType = .webSearch
        useInfoTextField.autocorrectionType = .no
        useInfoTextField.attributedPlaceholder = NSAttributedString(string: "请输入要搜索的用户名", attributes: [NSFontAttributeName : UIFont.systemFont(ofSize: 14),NSForegroundColorAttributeName : UIColor.orange])
        useInfoTextField.tintColor = UIColor.orange
        let padding :CGFloat = 10.0
        let rowH :CGFloat = 44
        let _ = useInfoTextField.mas_makeConstraints { (make) in
            let _ =  make?.left.equalTo()(self.view.mas_left)?.offset()(padding)
            let _ = make?.right.equalTo()(self.view.mas_right)?.offset()(-padding)
            let _ = make?.top.equalTo()(self.view.mas_top)?.offset()(padding * 2)
            let _ = make?.height.equalTo()(rowH)
        }
 
        //tableView
        let tabView = UITableView(frame: CGRect.zero, style: .plain)
        self.view.addSubview(tabView)
        self.tabView = tabView
        tabView.delegate = self
        tabView.dataSource = self
        tabView.rowHeight = 54
        tabView.separatorInset = UIEdgeInsetsMake(1, -100, 1, -100)
        tabView.register(UINib.init(nibName: "SearchUserNameTableViewCell", bundle: nil), forCellReuseIdentifier: ID)
        let _ = tabView.mas_makeConstraints { (make) in
            let _ = make?.left.equalTo()(self.view.mas_left)?.offset()(padding)
            let _ = make?.right.equalTo()(self.view.mas_right)?.offset()(-padding)
            let _ = make?.top.equalTo()(useInfoTextField.mas_bottom)?.offset()(padding)
            let _ = make?.height.equalTo()(UIScreen.main.bounds.height - rowH - padding)
        }
        
    }

    
    //MARK: - tableView datasource
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.searchResultArray.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: ID) as! SearchUserNameTableViewCell
        if  indexPath.row < self.searchResultArray.count{
            cell.dataSource = self.searchResultArray[indexPath.row]
        }
        if indexPath.row < self.searchLangArray.count {
            cell.favirLanguageLabel.text = self.searchLangArray[indexPath.row].language
        }
        return cell
    }
    //MARK: - textField delegate
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        self.searchUsNameModel?.inputStr = textField.text ?? ""
        self.searchFavirLagModel?.inputStr = textField.text ?? ""
        self.searchFavirLagModel?.refreashDataAndShow()
        self.searchUsNameModel?.refreashDataAndShow()
        
        return true
    }
    ////MARK: - 根据需求“实时更新”这里是没输入一个字符拉取一次数据。当然若果想做成像百度那种的实时搜索，拉取方法肯定不行，要用WebSocket 方式的长链接。第一次链接后后续不断开。
    func textFieldShouldEndEditing(_ textField: UITextField) -> Bool {
//        self.searchUsNameModel?.inputStr = textField.text ?? ""
//        self.searchFavirLagModel?.inputStr = textField.text ?? ""
//        searchFavirLagModel?.refreashDataAndShow()
//        searchUsNameModel?.refreashDataAndShow()
        return true
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        self.view.endEditing(true)
    }
    //MARK: - custem method
    private  func reloadData(){
        self.searchUsNameModel = SearchUserNameModel()
        self.searchFavirLagModel = SearchFavirLagModel()
        //MARK: - 这里可以使用信号量 偷了个懒用了两个bool
        self.searchUsNameModel?.dataSourceCallBack = { [unowned self] (dataSource) in

            self.searchResultArray = dataSource
            self.searchUsNameIsFinished = true
            self.refreashUI()
        }
        self.searchFavirLagModel?.dataSourceCallBack = { [unowned self] (dataSource) in
 
            self.searchLangArray = dataSource
            self.searchFirLangIsFinished = true
            self.refreashUI()
        }
    }

    func  refreashUI(){
    if self.searchUsNameIsFinished == true && self.searchFirLangIsFinished == true {
    self.tabView?.reloadData()
    self.searchUsNameIsFinished = false
    self.searchFirLangIsFinished = false
    }
    }
}
