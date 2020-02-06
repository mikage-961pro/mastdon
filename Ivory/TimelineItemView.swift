//
//  TimelineItem.swift
//  Ivory
//
//  Created by Asko Nomm on 31/07/2019.
//  Copyright © 2019 Asko Nomm. All rights reserved.
//

import Foundation
import UIKit
import Atributika

class TimelineItem: UIViewController {
    
    var item: [String: Any]!
    var isReblog: Bool = false
    var time: String = ""
    var entry: String = ""
    var mentions: AnyObject!
    var media: [[String: Any]]!
    var reblog: Bool = false
    var reblogAccount: [String: Any]!
    var reblogAccountHandle: String = ""
    var reblogAccountAvatarURL: String = ""
    var account: [String: Any]!
    var accountId: String = ""
    var accountName: String = ""
    var accountHandle: String = ""
    var accountAvatarURL: String = ""
    var accountInstanceURL: String = ""
    var cell: UICollectionViewCell!
    var collectionViewItemView: UIView!
    
    public func reblogHandleView() {
        
        let reblog: [String: Any] = self.item["reblog"] as? [String: Any] ?? [:]
        
        if(reblog.count > 0) {
            
            let account = self.item["account"] as! [String: Any]
            let accountHandle = account["display_name"] as? String ?? ""
            let reblogHandleView = UILabel(frame: CGRect(x: 50, y: 16, width: self.collectionViewItemView.frame.width - 30, height: 20))
            
            let openProfileGesture = OpenProfileGesture(target: self, action: #selector(openProfile))
            
            openProfileGesture.accountId = account["id"] as? String
            
            reblogHandleView.isUserInteractionEnabled = true
            reblogHandleView.addGestureRecognizer(openProfileGesture)
            reblogHandleView.text = accountHandle + " boosted"
            reblogHandleView.font = UIFont(name: reblogHandleView.font.fontName, size: 12)
            reblogHandleView.textColor = UIColor.darkGray
            
            self.cell.addSubview(reblogHandleView)
            
        }
        
    }
    
    public func rebloggerAvatarView() {
        
        let reblog: [String: Any] = self.item["reblog"] as? [String: Any] ?? [:]
        
        if(reblog.count > 0) {

            let account = self.item["account"] as! [String: Any]
            let accountAvatarURL = account["avatar"] as? String ?? ""
            let rebloggerAvatarView = CachedImageView(frame: CGRect(x: 15, y: 15, width: 25, height: 25))
            
            rebloggerAvatarView.layer.masksToBounds = false
            rebloggerAvatarView.layer.cornerRadius = rebloggerAvatarView.frame.height / 2
            rebloggerAvatarView.clipsToBounds = true
            
            let openProfileGesture = OpenProfileGesture(target: self, action: #selector(openProfile))
            
            openProfileGesture.accountId = account["id"] as? String
            
            rebloggerAvatarView.isUserInteractionEnabled = true
            rebloggerAvatarView.addGestureRecognizer(openProfileGesture)
            
            DispatchQueue.global().async {
                
                rebloggerAvatarView.loadImage(from: accountAvatarURL)
                
            }

            self.cell.addSubview(rebloggerAvatarView)
        
        }
        
    }
    
    public func avatarView() {
        
        let reblog: [String: Any] = self.item["reblog"] as? [String: Any] ?? [:]
        var avatarRect = CGRect(x: 15, y: 15, width: 25, height: 25)
        var accountAvatarURL: String!
        let account = self.item["account"] as! [String: Any]
        var accountId: String!
        let reblogAccount = reblog["account"] as? [String: Any] ?? [:]
        
        if(reblog.count > 0) {
            
            avatarRect = CGRect(x: 15, y: 55, width: 25, height: 25)
            accountId = reblogAccount["id"] as? String
            accountAvatarURL = reblogAccount["avatar"] as? String
            
        } else {
            
            accountId = account["id"] as? String
            accountAvatarURL = account["avatar"] as? String
            
        }
    
        let avatarView = CachedImageView(frame: avatarRect)
        
        avatarView.layer.borderWidth = 0
        avatarView.layer.masksToBounds = false
        avatarView.layer.borderColor = UIColor.black.cgColor
        avatarView.layer.cornerRadius = avatarView.frame.height / 2
        avatarView.clipsToBounds = true
        
        let openProfileGesture = OpenProfileGesture(target: self, action: #selector(openProfile))
        
        openProfileGesture.accountId = accountId

        avatarView.isUserInteractionEnabled = true
        avatarView.addGestureRecognizer(openProfileGesture)
        
        DispatchQueue.global().async {
            
            avatarView.loadImage(from: accountAvatarURL)
            
        }
        
        self.cell.addSubview(avatarView)
        
    }
    
    public func nameView() {
        
        let reblog: [String: Any] = self.item["reblog"] as? [String: Any] ?? [:]
        var nameRect = CGRect(x: 50, y: 19, width: 200, height: 20)
        let account = self.item["account"] as! [String: Any]
        let reblogAccount = reblog["account"] as? [String: Any] ?? [:]
        var accountName: String!
        var accountId: String
        var accountHandle: String!
        
        if(reblog.count > 0) {
            
            nameRect = CGRect(x: 50, y: 59, width: 200 , height: 20)
            accountId = reblogAccount["id"] as! String
            accountName = reblogAccount["display_name"] as? String
            accountHandle = reblogAccount["acct"] as? String
            
        } else {
            
            accountId = account["id"] as! String
            accountName = account["display_name"] as? String
            accountHandle = account["acct"] as? String
            
        }
        
        let nameView = UILabel(frame: nameRect)
        
        let openProfileGesture = OpenProfileGesture(target: self, action: #selector(openProfile))
        
        openProfileGesture.accountId = accountId
        
        nameView.isUserInteractionEnabled = true
        nameView.addGestureRecognizer(openProfileGesture)
        
        nameView.text = accountName
        nameView.font = UIFont.boldSystemFont(ofSize: 12.5)
        nameView.sizeToFit()
        
        self.cell.addSubview(nameView)
        
        // handle
        var handleRectWidth = self.view.frame.width - nameView.frame.width
        var handleRect = CGRect(x: nameView.frame.width + 55, y: 17, width: handleRectWidth - 100, height: 20)
        
        if(reblog.count > 0) {
            
            handleRect = CGRect(x: nameView.frame.width + 55, y: 57, width: handleRectWidth - 100, height: 20)
            
        }
        
        let handleView = UILabel(frame: handleRect)
    
        handleView.isUserInteractionEnabled = true
        handleView.addGestureRecognizer(openProfileGesture)
        
        if(!accountHandle.contains("@")) {
            
            handleView.text = "You"
            
        } else {
            
            handleView.text = "@" + accountHandle
            
        }
        
        handleView.font = UIFont(name: handleView.font.fontName, size: 12)
        handleView.textColor = UIColor.gray
  
        self.cell.addSubview(handleView)
        
    }
    
    public func timeView() {
        
        let reblog: [String: Any] = self.item["reblog"] as? [String: Any] ?? [:]
        var timeRect = CGRect(x: self.collectionViewItemView.frame.width - 65, y: 17, width: 50, height: 20)
        
        if(reblog.count > 0) {
            
            timeRect = CGRect(x: self.collectionViewItemView.frame.width - 65, y: 57, width: 50, height: 20)
            
        }
        
        let datetime = self.item["created_at"] as! String
        let timeView = UILabel(frame: timeRect)
        
        timeView.text = Utils().relativeTime(datetime: datetime)
        timeView.font = UIFont(name: timeView.font.fontName, size: 12)
        timeView.textColor = UIColor.lightGray
        timeView.textAlignment = .right
        
        self.cell.addSubview(timeView)
        
    }
    
    @discardableResult public func entryView(facade: Bool) -> CGFloat? {
        
        let reblog: [String: Any] = self.item["reblog"] as? [String: Any] ?? [:]
        var media: [[String: Any]]
        var entryOffsetFromTop: CGFloat = 55
        
        if(reblog.count > 0) {
            
            entryOffsetFromTop = 95
            media = reblog["media_attachments"] as! [[String: Any]]
            
        } else {
            
            media = self.item["media_attachments"] as! [[String: Any]]
            
        }
        
        let mentions = self.item["mentions"] as! [[String: Any]]

        // Hack solution for when the toot comes with no paragraph
        // For whatever reason that may be
        var entry = self.item["content"] as! String
        
        if(entry.prefix(3) != "<p>") {
            
            entry = "<p>" + entry + "</p>"
            
        }
        
        let entryTextParsed = entry
            .replacingOccurrences(of: "</p>", with: "\n\r")
            .replacingOccurrences(of: "<p>", with: "")
            .replacingOccurrences(of: "<br>", with: "\n")
        
        let entryView = AttributedLabel(frame: CGRect(x: 15, y: entryOffsetFromTop, width: self.collectionViewItemView.frame.width - 30, height: self.collectionViewItemView.frame.height - 80))
        let entryStyle = NSMutableParagraphStyle()

        entryStyle.lineSpacing = 5
        entryStyle.paragraphSpacing = 0
        
        let all = Style.font(.systemFont(ofSize: 12.5, weight: UIFont.Weight.regular)).paragraphStyle(entryStyle)
        let blue = UIColor(red: 43.0/255.0, green: 144.0/255.0, blue: 217.0/255.0, alpha: 1.0)
        let link = Style("a")
            .foregroundColor(blue, .normal)
            .foregroundColor(.black, .highlighted) // <-- detections with this style will be clickable now
        
        entryView.attributedText = entryTextParsed
            .style(tags: link)
            .styleHashtags(link)
            .styleMentions(link)
            .styleLinks(link)
            .styleAll(all)
        
        entryView.numberOfLines = 0
        entryView.isSelectable = true
        entryView.sizeToFit()
        
        entryView.onClick = { label, detection in
            switch detection.type {
            case .hashtag(let tag):
                self.entryActionForHashtag(tag)
            case .mention(let name):
                self.entryActionForMention(name, mentions: mentions)
            case .link(let url):
                self.entryActionForURL(url)
            case .tag(let tag):
                if tag.name == "a", let href = tag.attributes["href"], let url = URL(string: href) {
                    self.entryActionForURL(url)
                }
            default:
                break
            }
        }
        
        if(!facade) {
            
            self.cell.addSubview(entryView)
        
        }
        
        // Media
        var mediaViewOffsetFromTop: CGFloat = entryView.frame.height + 30
        
        if(reblog.count > 0) {
            
            mediaViewOffsetFromTop = entryView.frame.height + 70
            
        }
        
        if(media.count > 0) {
            
            for mediaItem in media {
                
                let type: String = mediaItem["type"] as! String
                
                if(type == "image" || type == "gifv") {
                    
      
                    let previewURL: String = mediaItem["preview_url"] as! String
                    //let remoteURL: String = mediaItem["remote_url"] as! String
                    let imageView = CachedImageView(frame: CGRect(x: 0, y: mediaViewOffsetFromTop, width: self.collectionViewItemView.frame.width, height: 200))
                    
                    imageView.layer.borderWidth = 0.5
                    imageView.layer.masksToBounds = false
                    imageView.layer.borderColor = UIColor(red:0.87, green:0.87, blue:0.87, alpha:1.0).cgColor
                    imageView.layer.cornerRadius = 0
                    imageView.clipsToBounds = true
                    imageView.center.x = self.collectionViewItemView.center.x
       
                    DispatchQueue.global().async {
                        
                        imageView.loadImage(from: previewURL)
                        
                    }
                    
                    if(!facade) {
                        
                        self.cell.addSubview(imageView)
                        
                    }
                    
                    mediaViewOffsetFromTop = mediaViewOffsetFromTop + 200
                    
                }
                
            }
        }
        
        var entryViewHeight: CGFloat = entryView.frame.height + 35
        
        // Reblogged?
        if(reblog.count > 0) {
            
            entryViewHeight = entryViewHeight + 40
            
        }
        
        // Media?
        if(media.count > 0) {
            
            for mediaItem in media {
                
                entryViewHeight = entryViewHeight + 220
                
            }
            
        }
        
        if(facade) {
            
            return entryViewHeight
            
        } else {
            
            return nil
            
        }
        
    }
    
    public func build() -> UICollectionViewCell {
        
        // Are we dealing with a reblog?
        let reblog: [String: Any] = self.item["reblog"] as? [String: Any] ?? [:]
        
        if(reblog.count > 0) {
            
            self.cell.backgroundColor = UIColor(red:0.97, green:0.97, blue:0.97, alpha:1.0)
            
        } else {
            
            self.cell.backgroundColor = UIColor.white
            
        }
        
        // Compose the components
        self.reblogHandleView()
        self.avatarView()
        self.rebloggerAvatarView()
        self.nameView()
        self.timeView()
        self.entryView(facade: false)
        self.bottomBorder()
        
        // Off we go
        return self.cell
        
    }
    
    public func height() -> CGFloat {
        
        return self.entryView(facade: true)!
        
    }
    
    /**
     Directs a user to the HashtagViewController of the tapped hashtag.
     
     - Parameter hashtag: The hashtag to be viewed.
     
     - Returns: void.
     */
    func entryActionForHashtag(_ hashtag: String) {
        
        print(hashtag)
        
    }
    
    /**
     Directs a user to the ProfileViewController of the tapped user.
     
     - Parameter handle: The username of the user.
     - Parameter mentions: all of the mentions in the toot.
     
     - Returns: void.
     */
    func entryActionForMention(_ handle: String, mentions: [[String: Any]]) {
        
        for mention in mentions {
            
            let id = mention["id"] as! String
            let username = mention["username"] as! String
            
            if(username == handle) {
                
                // before we dispatch this, we need to get the user's account object
                let openProfileGesture = OpenProfileGesture()

                openProfileGesture.accountId = id
                
                self.openProfile(sender: openProfileGesture)
                
                break
                
            }
        }
        
    }
    
    /**
     Opens the given URL in a browser.
     
     - Parameter url: The constructed URL object.
     
     - Returns: void.
     */
    func entryActionForURL(_ url: URL) {
        
        UIApplication.shared.open(url)
        
    }
    
    public func bottomBorder() {
        
        // Bottom border
        let gray = UIColor(red: 0.87, green: 0.87, blue: 0.87, alpha: 1.0)
        let borderBottom = UIView(frame: CGRect(x: 0, y: self.cell.frame.height - 0.6, width: self.cell.frame.width, height: 0.6))
        
        borderBottom.backgroundColor = gray
        
        self.cell.addSubview(borderBottom)
        
    }
    
    @objc public func openProfile(sender: OpenProfileGesture) {

        OperationQueue.main.addOperation {
            
            if var topController = UIApplication.shared.keyWindow?.rootViewController {
                
                while let presentedViewController = topController.presentedViewController {
                    
                    topController = presentedViewController
                    
                }
                
                let vc = ProfileViewController()
                
                vc.accountId = sender.accountId
                
                let navigationController = UINavigationController()
                
                navigationController.viewControllers = [vc]
                
                topController.present(navigationController, animated: false, completion: nil)
                
            }
            
        }
        
    }
    
}
