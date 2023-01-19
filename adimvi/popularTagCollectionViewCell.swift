
//  popularTagCollectionViewCell.swift
//  adimvi
//  Created by javed carear  on 20/05/1942 Saka.
//  Copyright © 1942 webdesky.com. All rights reserved.

import UIKit
import TangramKit

protocol PopularTagDeleagte {
    func didTapTagDelegate(tag: [String: Any])
}

class popularTagCollectionViewCell: UICollectionViewCell {
    
    var delegate: PopularTagDeleagte?
    var data = [[String: Any]]()
    
    func initCell(data: [[String: Any]]) {
        self.data = data
        initWrapView(data: data)
    }
    
    func initWrapView(data: [[String: Any]]) {
        
        let S = TGFloatLayout(.vert)
        S.tg_useFrame = true
        S.tg_height.equal(.wrap)
        S.tg_width.equal(self.contentView.frame.size.width)
        S.tg_top.equal(0.0)
        S.tg_leadingPadding = 10.0
        S.tg_trailingPadding = 10.0
        
        let deviceHeight: CGFloat = UIScreen.main.bounds.height
        let height: CGFloat = deviceHeight > 700 ? 30.0 : 28.0
        let fontSize: CGFloat = deviceHeight > 700 ? 14.0 : 13.0
        let widthExtra: CGFloat = deviceHeight > 700 ? 50.0 : 40.0
        let cornerRadius: CGFloat = deviceHeight > 700 ? 15.0 : 14.0
        
        
        S.tg_space = deviceHeight > 700 ? 15.0 : 12.0
        
        var paragrphCnt: Int = 0
        var labelTotalWidth: CGFloat = 10.0
        for i in 0..<data.count {
            let item = data[i]
            let label = UIButton()
            let tag = item["tags"] as? String
            label.setTitle(tag, for: .normal)
            label.titleLabel?.font = UIFont.systemFont(ofSize: fontSize)
            label.setTitleColor(UIColor(named: "Dark grey (Dark mode)"), for: .normal)
            label.tg_height.equal(height)
            let labelWidth: CGFloat = tag!.width(withConstrainedHeight: 24.0, font: .systemFont(ofSize: fontSize)) + widthExtra
            labelTotalWidth += labelWidth + 10.0
            if labelTotalWidth > self.contentView.frame.size.width {
                paragrphCnt += 1
                labelTotalWidth = 10.0 + labelWidth
            }
            label.tg_width.equal(labelWidth)
            label.layer.cornerRadius = cornerRadius
            label.layer.borderWidth = 1.0
            label.layer.borderColor = UIColor.lightGray.cgColor
            label.tag = i
            label.addTarget(self, action: #selector(onTapActionUB), for: .touchUpInside)
            S.addSubview(label)
        }
        self.contentView.addSubview(S)
//        let S_height = (24.0 + 10.0) * CGFloat(paragrphCnt + 1)
//        return (topPosition + S_height)
    }
    
    @objc func onTapActionUB(sender: UIButton) {
        self.delegate?.didTapTagDelegate(tag: self.data[sender.tag])
    }
}
