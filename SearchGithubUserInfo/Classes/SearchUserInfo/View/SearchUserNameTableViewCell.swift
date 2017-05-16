//
//  SearchUserNameTableViewCell.swift
//  SearchGithubUserInfo
//
//  Created by menhao on 17/5/16.
//  Copyright © 2017年 menhao. All rights reserved.
//

import UIKit

class SearchUserNameTableViewCell: UITableViewCell {
    //MARK: - property
    @IBOutlet weak var nameLabel: UILabel!
    @IBOutlet weak var iconImageV: UIImageView!
    @IBOutlet weak var favirLanguageLabel: UILabel!
    //MARK: - getter and setter
    var dataSource : SearchUserNameModel? {
        willSet{
            self.dataSource = newValue
            self.nameLabel.text = dataSource?.login
            if self.dataSource?.avatar_url == ""{
            self.iconImageV.image = UIImage.init(named: "placehloder")
                return
            }
            self.iconImageV.layer.cornerRadius = 6.0   //偷懒了 这么写有性能损失 正确的写法应该在下面
            self.iconImageV.layer.masksToBounds = true
           self.iconImageV.sd_setImage(with:  URL.init(string: (self.dataSource?.avatar_url)! + "&s=400"), placeholderImage: UIImage.init(named: "placehloder"), options: .retryFailed) { (image, err, _, _) in
                //在这里设置圆角的话
            }
        }
    
    }
}
