//
//  ViewController.swift
//  ImageBug
//
//  Created by Sash Zats on 7/27/16.
//  Copyright © 2016 Sash Zats. All rights reserved.
//

import UIKit
import AsyncDisplayKit

struct ViewModel {
    struct Deal {
        let upTo: Bool
    }

    let storeLogo: UIImage

    let hasPresentedDeal: Bool
    let storeWideDealDescription: String
    let presentedDeal: Deal?

    let multiplierImage: UIImage?
}

class ViewController: UIViewController {
    private var viewModels: [ViewModel] = []
    @IBOutlet weak var collectionView: UICollectionView!

    override func viewDidLoad() {
        super.viewDidLoad()
        collectionView.registerClass(Cell.self, forCellWithReuseIdentifier: "Cell")
        populateData()
    }

    private func populateData() {
        viewModels = (0..<100).map { _ in
            let deal = ViewModel.Deal(upTo: .random())

            let logo = UIImage(named: "store-logo")!
            let multiplier = UIImage(named: "multiplier")!

            let discount = "\(Int.random())% OFF"
            let hasMultiplier = Bool.random()
            let viewModel = ViewModel(
                storeLogo: logo,
                hasPresentedDeal: .random(),
                storeWideDealDescription: discount,
                presentedDeal: deal,
                multiplierImage: hasMultiplier ? multiplier : nil)
            return viewModel
        }
    }
}


extension ViewController: UICollectionViewDataSource {
    func collectionView(collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return viewModels.count
    }

    func collectionView(collectionView: UICollectionView, cellForItemAtIndexPath indexPath: NSIndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCellWithReuseIdentifier("Cell", forIndexPath: indexPath) as! Cell
        let viewModel = viewModels[indexPath.item]
        configure(node: cell.node, with: viewModel)
        return cell
    }

    private func configure(node node: StoreNode, with viewModel: ViewModel) {
        node.storeLogo.image = viewModel.storeLogo

        if viewModel.hasPresentedDeal {
            node.discount.text = viewModel.storeWideDealDescription
            node.discount.upTo = viewModel.presentedDeal?.upTo == true
            node.discount.hidden = false
        } else {
            node.discount.hidden = true
        }

        node.multiplier.hidden = false
        node.multiplier.image = viewModel.multiplierImage
    }
}

class Cell: UICollectionViewCell {
    private lazy var node = StoreNode()

    override init(frame: CGRect) {
        super.init(frame: frame)
        setup()
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    private func setup() {
        contentView.layer.addSubnode(node)
    }

    override func layoutSubviews() {
        super.layoutSubviews()
        node.frame = contentView.bounds
        node.measure(contentView.bounds.size)
    }

    override func prepareForReuse() {
        super.prepareForReuse()
        node.storeLogo.image = nil
    }
}

class StoreNode: ASDisplayNode {
    private lazy var storeLogo: ASImageNode = {
        let node = ASImageNode()
        node.clipsToBounds = true
        node.backgroundColor = .whiteColor()
        node.borderWidth = 1
        node.borderColor = UIColor.wml_warmGray().CGColor
        node.cornerRadius = 20
        return node
    }()

    private lazy var multiplier: ASImageNode = {
        let node = ASImageNode()
        node.contentMode = .ScaleAspectFit
        return node
    }()

    private lazy var discount = DiscountNode()


    override init() {
        super.init()
        addSubnode(storeLogo)
        addSubnode(discount)
        addSubnode(multiplier)
    }

    override func layoutSpecThatFits(constrainedSize: ASSizeRange) -> ASLayoutSpec {
        return ASOverlayLayoutSpec(
            child: ASRatioLayoutSpec(ratio: 1, child: storeLogo),
            overlay: ASOverlayLayoutSpec(
                child: ASStackLayoutSpec(
                    direction: .Vertical,
                    spacing: 0,
                    justifyContent: .End,
                    alignItems: .Center, children: [
                        ASInsetLayoutSpec(
                            insets: UIEdgeInsets(top: 0, left: 0, bottom: -5, right: 0),
                            child: discount)
                    ]),
                overlay: ASStackLayoutSpec(
                    direction: .Horizontal,
                    spacing: 0,
                    justifyContent: .End,
                    alignItems: .Start, children: [
                        ASInsetLayoutSpec(
                            insets: UIEdgeInsets(top: -2, left: 0, bottom: 0, right: -2),
                            child: multiplier)
                    ])))
    }
}

private class DiscountNode: ASDisplayNode {
    var text: String? {
        set {
            guard let text = newValue else {
                label.attributedText = nil
                setNeedsLayout()
                return
            }
            label.attributedText = NSAttributedString(
                string: text,
                attributes: [
                    NSForegroundColorAttributeName: UIColor.whiteColor(),
                    NSFontAttributeName: UIFont.wml_semiBoldFontOfSize(16)
                ])
            setNeedsLayout()
        }
        get {
            return label.attributedText?.string
        }
    }

    var upTo: Bool {
        set {
            upToDiscount.hidden = !newValue
            setNeedsLayout()
        }
        get {
            return !upToDiscount.hidden
        }
    }

    private lazy var label: ASTextNode = {
        let label = ASTextNode()
        label.maximumNumberOfLines = 1
        return label
    }()

    private lazy var upToDiscount: ASImageNode = {
        let node = ASImageNode()
        node.contentMode = .ScaleAspectFit
        node.image = UIImage(named:"sale-sign-word-upto-icon")
        return node
    }()


    override init() {
        super.init()
        borderColor = UIColor(white: 1, alpha: 0.4).CGColor
        borderWidth = 0.5
        cornerRadius = 5
        backgroundColor = .wml_red()
        addSubnode(label)
        addSubnode(upToDiscount)
    }

    override func layoutSpecThatFits(constrainedSize: ASSizeRange) -> ASLayoutSpec {
        let childern = [upToDiscount, label].filter {
            return !$0.hidden
            }
            .map {
                return ASInsetLayoutSpec(
                    insets: UIEdgeInsets(top: 0, left: 5, bottom: 0, right: 5),
                    child: $0)
        }
        return ASStackLayoutSpec(
            direction: .Horizontal,
            spacing: -7,
            justifyContent: .End,
            alignItems: .Center,
            children: childern)
    }
}

extension UIColor {
    static func wml_warmGray() -> UIColor {
        return .grayColor()
    }

    static func wml_red() -> UIColor {
        return .redColor()
    }
}

extension UIFont {
    static func wml_semiBoldFontOfSize(size: CGFloat) -> UIFont {
        return UIFont.boldSystemFontOfSize(size)
    }
}

extension Bool {
    static func random() -> Bool {
        return arc4random_uniform(10) > 5
    }
}

extension Int {
    static func random() -> Int {
        return Int(arc4random_uniform(100))
    }
}