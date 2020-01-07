//
//  EmojiArtViewController.swift
//  EmojiArt
//
//  Created by Jorge Encinas on 16/12/19.
//  Copyright © 2019 Jorge Encinas. All rights reserved.
//

import UIKit

class EmojiArtViewController: UIViewController {
    
    var imageFetcher: ImageFetcher!
    var emojis = "🐼🌾🍄🌲🌴🥀🌧☁️🌩🦃🐇🐆🦜🦥🕊🦅🦆🐝🦒🦌🐿".map { String($0) }
    
    @IBOutlet weak var dropZone: UIView!{
        didSet{
            dropZone.addInteraction(UIDropInteraction(delegate: self))
        }
    }
    
    var emojiArtView = EmojiArtView()
    @IBOutlet weak var scrollView: UIScrollView!{
        didSet{
            scrollView.minimumZoomScale = 0.1
            scrollView.maximumZoomScale = 5.0
            scrollView.delegate = self
            scrollView.addSubview(emojiArtView)
        }
    }
    
    @IBOutlet weak var scrollViewWidth: NSLayoutConstraint!
    @IBOutlet weak var scrollViewHeight: NSLayoutConstraint!
    
    func viewForZooming(in scrollView: UIScrollView) -> UIView?{
        return emojiArtView
    }
    
    var emojiArtBackgroundImage: UIImage?{
        get{
            return emojiArtView.backgroundImage
        }
        set{
            scrollView?.zoomScale = 1.0
            emojiArtView.backgroundImage = newValue
            let size = newValue?.size ?? CGSize.zero
            emojiArtView.frame = CGRect(origin: CGPoint.zero, size: size)
            scrollView?.contentSize = size
            scrollViewHeight?.constant = size.height
            scrollViewWidth?.constant = size.width
            if let dropZone = self.dropZone, size.width > 0, size.height > 0{
                scrollView?.zoomScale = max(dropZone.bounds.size.width / size.width, dropZone.bounds.size.height / size.height)
            }
        }
    }
    
    @IBOutlet weak var emojiCollectionView: UICollectionView!{
        didSet{
            emojiCollectionView.dataSource = self
            emojiCollectionView.delegate = self
            emojiCollectionView.dragDelegate = self
            emojiCollectionView.dropDelegate = self
        }
    }
    
    private var font: UIFont{
        return UIFontMetrics(forTextStyle: .body).scaledFont(for: UIFont.preferredFont(forTextStyle: .body).withSize(60))
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
    }
    

}

extension EmojiArtViewController: UIDropInteractionDelegate{
    
    //Solo si el objeto que estas arrojando es del tipo de clases NSURL y UIIMage continuara con sessionDidUpdate
    func dropInteraction(_ interaction: UIDropInteraction, canHandle session: UIDropSession) -> Bool {
        print("dropInteraction canHandle")
        return session.canLoadObjects(ofClass: NSURL.self) && session.canLoadObjects(ofClass: UIImage.self)
    }
    
    //Todo lo q se deje en la zona se va copiar ya que puede recibir de otras apps
    func dropInteraction(_ interaction: UIDropInteraction, sessionDidUpdate session: UIDropSession) -> UIDropProposal {
        print("dropInteraction canHandle")
        return UIDropProposal(operation: .copy)
    }
    
    func dropInteraction(_ interaction: UIDropInteraction, performDrop session: UIDropSession) {
        print("dropInteraction performDrop")
        self.imageFetcher = ImageFetcher() { (url, image) in
            DispatchQueue.main.async {
                self.emojiArtBackgroundImage = image
            }
        }
        
        session.loadObjects(ofClass: NSURL.self, completion: {nsurls in
            if let url = nsurls.first as? URL{
                self.imageFetcher.fetch(url)
            }
        })
        
        session.loadObjects(ofClass: UIImage.self, completion: {images in
            if let image = images.first as? UIImage{
                self.imageFetcher.backup = image
            }
        })
    }
    
}

extension EmojiArtViewController: UIScrollViewDelegate{
    
    func scrollViewDidZoom(_ scrollView: UIScrollView) {
        scrollViewWidth.constant = scrollView.contentSize.width
        scrollViewHeight.constant = scrollView.contentSize.height
    }
    
}

extension EmojiArtViewController: UICollectionViewDelegate, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout {
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return emojis.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "EmojiCell", for: indexPath)
        if let emojiCell = cell as? EmojiCollectionViewCell{
            let text = NSAttributedString(string: emojis[indexPath.item], attributes: [.font : font])
            emojiCell.label.attributedText = text
        }
        return cell
    }
    
}

extension EmojiArtViewController: UICollectionViewDragDelegate{
    
    private func dragItems(at indexPath: IndexPath) -> [UIDragItem] {
        if let attributedString = (emojiCollectionView.cellForItem(at: indexPath) as? EmojiCollectionViewCell)?.label.attributedText{
            let dragItem = UIDragItem(itemProvider: NSItemProvider(object: attributedString))
            dragItem.localObject = attributedString
            return [dragItem]
        } else{
            return []
        }
    }
    
    //Start the drag
    func collectionView(_ collectionView: UICollectionView, itemsForBeginning session: UIDragSession, at indexPath: IndexPath) -> [UIDragItem] {
        session.localContext = collectionView //(1) Para despues cuando se haga el drop, saber si estamos haciendo drop en nuestra collection de emojis y no dejarlo solo hacer .move
        return dragItems(at: indexPath)
    }
    
    //agregar multiples
    
    func collectionView(_ collectionView: UICollectionView, itemsForAddingTo session: UIDragSession, at indexPath: IndexPath, point: CGPoint) -> [UIDragItem] {
        return dragItems(at: indexPath)
    }
    
}

extension EmojiArtViewController: UICollectionViewDropDelegate{
    
    func collectionView(_ collectionView: UICollectionView, canHandle session: UIDropSession) -> Bool {
        return session.canLoadObjects(ofClass: NSAttributedString.self)
    }
    
    func collectionView(_ collectionView: UICollectionView, dropSessionDidUpdate session: UIDropSession, withDestinationIndexPath destinationIndexPath: IndexPath?) -> UICollectionViewDropProposal {
        let isSelf = (session.localDragSession?.localContext as? UICollectionView) == collectionView //(1)
        return UICollectionViewDropProposal(operation: isSelf ? .move : .copy, intent: .insertAtDestinationIndexPath)
    }
    
    func collectionView(_ collectionView: UICollectionView, performDropWith coordinator: UICollectionViewDropCoordinator) {
        
    }
    
}
