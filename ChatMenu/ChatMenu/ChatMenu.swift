//
//  ChatMenu.swift
//  ChatMenu
//
//  Created by Tan on 2017/8/12.
//
import UIKit

public extension ChatMenu {

    /// Show a menu on a particular chat bubble view, with an action sheet
    /// attached to it.
    ///
    /// - Parameters:
    ///   - bubbleView: Chat bubble view.
    ///   - direction: The direction in which the bubble view is located.
    ///   - actions: Actions of the action sheet in menu.
    ///   - items: Items to show on the bubble view, such as emoji.
    ///   - dismissCallback: Called when menu will dismiss.
    ///   - completedDismissCallback: Called when menu did dismiss.
    static func show(on bubbleView: UIView,
                     direction: Direction,
                     actions: [Action],
                     items: [BubbleItem],
                     dismissCallback: (() -> ())? = nil,
                     completedDismissCallback: (() -> ())? = nil) {
        let controller = ChatMenu.Controller(bubbleControllerConfig: ChatMenu.BubbleControllerConfig(direction: direction, items: items, bubbleView: bubbleView),
                                             actionSheetConfig: ChatMenu.ActionSheetConfig(actions: actions))
        controller.dismissCallback = dismissCallback
        controller.didCompletedDismissCallback = completedDismissCallback
        UIApplication.shared.keyWindow?.rootViewController?.present(controller, animated: true, completion: nil)
    }
}

public enum ChatMenu {
    public typealias BubbleItem = BubbleController.Item
    public typealias Action = ActionSheet.Action
    public typealias Direction = ChatMenu.BubbleController.Direction
}

public extension ChatMenu {
    struct BubbleControllerConfig {
        public let direction: ChatMenu.BubbleController.Direction
        public let items: [ChatMenu.BubbleController.Item]
        public let bubbleView: UIView
    }

    struct ActionSheetConfig {
        public let actions: [ChatMenu.ActionSheet.Action]
    }
}

public extension ChatMenu {
    final class BubbleController: UIViewController {

        fileprivate var _direction: Direction!
        fileprivate var _itemButtons: [_ItemButton]!
        fileprivate var _bubbleView: UIView!

        fileprivate var dismissCallback: (() -> ())?

        public init(direction: Direction, items: [Item], bubbleView: UIView) {
            super.init(nibName: nil, bundle: nil)
            _direction = direction
            _itemButtons = items.map(_ItemButton.init)
            _bubbleView = bubbleView

            if direction == .right {
                view.autoresizingMask = .flexibleLeftMargin
            }
        }

        override init(nibName nibNameOrNil: String?, bundle nibBundleOrNil: Bundle?) {
            super.init(nibName: nibNameOrNil, bundle: nibBundleOrNil)
        }

        public required init?(coder aDecoder: NSCoder) {
            fatalError("init(coder:) has not been implemented")
        }

        public override func viewDidLoad() {
            super.viewDidLoad()
            view.frame = BubbleController._calcFrame(direction: _direction, bubbleView: _bubbleView, itemsCount: _itemButtons.count)
            view.addSubview(_backgroundView)
            view.addSubview(_littleBubbleView)
            _setupViewsInitializedStatus()
            _littleBubbleView.frame.origin.x = BubbleController._obtainLittleBubbleViewX(direction: _direction, bubbleView: _bubbleView) - view.frame.origin.x
            view.isHidden = true
        }

        fileprivate lazy var _backgroundView: UIImageView = {
            let backgroundImage: UIImage? = .chatMenuImage(name: "menu-bubble-bg")
            let height = backgroundImage?.size.height ?? 0
            let width = backgroundImage?.size.width ?? 0
            let resizedBackgroundImage = backgroundImage?.resizableImage(withCapInsets: UIEdgeInsets(top: 0.5 * height, left: 0.5 * width, bottom: 0.5 * height, right: 0.5 * width))
            let view = UIImageView(image: resizedBackgroundImage)
            view.contentMode = .scaleToFill
            return view
        }()

        fileprivate lazy var _littleBubbleView: UIImageView = {
            let image: UIImage? = self._direction == .left ? .chatMenuImage(name: "menu-bubble-little-right") : .chatMenuImage(name: "menu-bubble-little-left")
            let view = UIImageView(image: image)
            view.contentMode = .scaleToFill
            return view
        }()

        // dismiss
        @objc fileprivate func _dismiss() {
            dismissCallback?()
        }
    }
}

// MARK: - Animation
extension ChatMenu.BubbleController {
    fileprivate func _setupViewsInitializedStatus() {
        _itemButtons.enumerated().forEach { index, view in
            view.frame.size = menuItemSize
            view.center.y = 0.5 * (self.view.bounds.height - menuViewHeight + menuBackgroundViewHeight)
            view.frame.origin.x = CGFloat(index) * (menuItemSize.width + menuItemOffset) + menuItemOffset

            // Tran
            view.transform = CGAffineTransform(rotationAngle: -CGFloat.pi * (30 / 360)).scaledBy(x: 0.01, y: 0.01)

            self.view.addSubview(view)
            view.addTarget(self, action: #selector(ChatMenu.BubbleController._dismiss), for: .touchUpInside)
        }
        _backgroundView.frame = CGRect(x: 0, y: 0, width: view.bounds.width, height: menuBackgroundViewHeight)
        _littleBubbleView.frame.size = menuLittleBubbleSize
        _littleBubbleView.frame.origin.y = view.bounds.height - menuLittleBubbleSize.height

        // Tran
        _backgroundView.transform = CGAffineTransform(scaleX: 0.6, y: 1)
        _backgroundView.alpha = 0
        _littleBubbleView.transform = CGAffineTransform(scaleX: 0.1, y: 0.1)
    }

    public func show(from viewController: UIViewController) {
        viewController.addChildViewController(self)
        viewController.view.addSubview(self.view)
        view.isHidden = false
        UIView.animate(withDuration: 0.25, delay: 0, usingSpringWithDamping: 0.5, initialSpringVelocity: 13, options: .curveEaseInOut, animations: {
            self._littleBubbleView.transform = CGAffineTransform.identity
        }, completion: nil)
        UIView.animate(withDuration: 0.25, delay: 0.08, usingSpringWithDamping: 0.5, initialSpringVelocity: 10, options: .curveEaseInOut, animations: {
            self._backgroundView.transform = CGAffineTransform.identity
            self._backgroundView.alpha = 1
        }, completion: nil)
        // 每个itemButton依次进行弹簧动画
        _itemButtons.enumerated().forEach { index, view in
            UIView.animate(withDuration: 0.50, delay: Double(index) * 0.09, usingSpringWithDamping: 0.25, initialSpringVelocity: 5, options: .curveEaseInOut, animations: {
                view.transform = CGAffineTransform.identity
            }, completion: nil)
        }
    }
}

// MARK: - Calc: 布局计算
fileprivate extension ChatMenu.BubbleController {
    static func _obtainExpectWidth(itemsCount: Int) -> CGFloat {
        let itemsCount = CGFloat(itemsCount)
        let width = itemsCount * menuItemSize.width + (itemsCount + 1) * menuItemOffset
        return width > menuBackgroundViewHeight ? width : menuBackgroundViewHeight
    }

    // 根据具体聊天气泡的方向、frame，以及菜单气泡的长度，计算菜单上方大气泡的frame
    static func _calcFrame(direction: ChatMenu.BubbleController.Direction, bubbleFrame: CGRect, expectWidth: CGFloat) -> CGRect {
        var x: CGFloat = 0
        if direction == .left {
            x = bubbleFrame.maxX - (expectWidth - menuHorizontalOffset)
            if x < bubbleFrame.origin.x { x = bubbleFrame.origin.x }
            x = min(UIScreen.main.bounds.width - expectWidth, x)
        } else {
            x = bubbleFrame.origin.x - menuHorizontalOffset
            if x + expectWidth > bubbleFrame.maxX { x = bubbleFrame.maxX - expectWidth }
            x = max(0, x)
        }
        let y = bubbleFrame.origin.y - menuVerticalOffset - menuBackgroundViewHeight
        return CGRect(x: x, y: y, width: expectWidth, height: menuViewHeight)
    }

    // 根据具体聊天气泡View以及其方向，菜单Item数，计算菜单上方大气泡的frame
    static func _calcFrame(direction: ChatMenu.BubbleController.Direction, bubbleView: UIView, itemsCount: Int) -> CGRect {
        let expectWidth = _obtainExpectWidth(itemsCount: itemsCount)
        let bubbleFrame: CGRect
        if let bubbleSuperView = bubbleView.superview {
            bubbleFrame = bubbleSuperView.convert(bubbleView.frame, to: UIApplication.shared.keyWindow)
        } else {
            bubbleFrame = bubbleView.frame
        }
        return _calcFrame(direction: direction, bubbleFrame: bubbleFrame, expectWidth: expectWidth)
    }

    // 计算下方两个小气泡的OY值
    static func _obtainLittleBubbleViewX(direction: ChatMenu.BubbleController.Direction, bubbleView: UIView) -> CGFloat {
        let bubbleFrame: CGRect
        if let bubbleSuperView = bubbleView.superview {
            bubbleFrame = bubbleSuperView.convert(bubbleView.frame, to: UIApplication.shared.keyWindow)
        } else {
            bubbleFrame = bubbleView.frame
        }
        // 根据BubbleView的具体大小Frame，进行微调
        if direction == .left {
            return bubbleFrame.maxX + 2
        } else {
            return bubbleFrame.origin.x - 6
        }
    }
}

fileprivate extension ChatMenu.BubbleController {
    final class _ItemButton: _ScaleForActivatedButton {
        fileprivate let _item: Item

        init(item: Item) {
            _item = item
            super.init(frame: .zero, scale: 1.5)
            titleLabel?.font = UIFont.systemFont(ofSize: 25)
            setImage(item.image, for: .normal)
            setTitle(item.title, for: .normal)
            addTarget(self, action: #selector(_ItemButton._action), for: .touchUpInside)
            imageView?.contentMode = .center
            layer.masksToBounds = false
            imageView?.layer.masksToBounds = false
        }

        required init?(coder aDecoder: NSCoder) {
            fatalError("init(coder:) has not been implemented")
        }

        @objc fileprivate func _action() {
            _item.action()
        }
    }
}

public extension ChatMenu.BubbleController {
    enum Direction {
        case left
        case right
    }

    struct Item {
        public let image: UIImage?
        public let title: String?
        public let action: () -> ()

        public init(title: String? = nil, image: UIImage? = nil, action: @escaping () -> ()) {
            self.image = image
            self.title = title
            self.action = action
        }
    }
}

// MARK: - ActionSheet
extension ChatMenu {
    public final class ActionSheet: UIViewController {
        fileprivate let _normalActionItems: [_ActionItem]
        fileprivate let _cancelActionItems: [_ActionItem]

        fileprivate var dismissCallback: (() -> ())?

        public init(actions: [Action]) {
            _normalActionItems = actions.filter { $0.style == .normal }.map(_ActionItem.init)
            _cancelActionItems = actions.filter { $0.style == .cancel }.map(_ActionItem.init)
            super.init(nibName: nil, bundle: nil)
            view.autoresizingMask = [.flexibleTopMargin, .flexibleWidth]
        }

        public required init?(coder aDecoder: NSCoder) {
            fatalError("init(coder:) has not been implemented")
        }

        // Views
        fileprivate lazy var _blurViewForNormal: UIVisualEffectView = {
            let effect = UIBlurEffect(style: .light)
            let view = UIVisualEffectView(effect: effect)
            return view
        }()

        fileprivate lazy var _contentViewForNormal: UIView = {
            let view = UIView()
            view.layer.masksToBounds = true
            view.layer.cornerRadius = actionSheetCorners
            view.autoresizingMask = .flexibleWidth
            return view
        }()

        fileprivate lazy var _blurViewForCancel: UIVisualEffectView = {
            let effect = UIBlurEffect(style: .light)
            let view = UIVisualEffectView(effect: effect)
            return view
        }()

        fileprivate lazy var _contentViewForCancel: UIView = {
            let view = UIView()
            view.layer.masksToBounds = true
            view.layer.cornerRadius = actionSheetCorners
            view.autoresizingMask = .flexibleWidth
            return view
        }()

        // GestureReconizer, Handle Items's Event
        @objc fileprivate func _listenFor(panGestureReconizer: UIPanGestureRecognizer) {
            let location = panGestureReconizer.location(in: view)
            let items = _normalActionItems + _cancelActionItems
            switch panGestureReconizer.state {
            case .began, .changed:
                for actionItem in items {
                    let point = actionItem.convert(location, from: view)
                    if actionItem.point(inside: point, with: nil) {
                        actionItem.switchToActive()
                    } else {
                        actionItem.switchToUnActive()
                    }
                }
            case .ended:
                for actionItem in items {
                    let point = actionItem.convert(location, from: view)
                    if actionItem.point(inside: point, with: nil) {
                        actionItem.doAction()
                        dismissCallback?()
                    }
                }
            default:
                ()
            }
        }

        // dismiss
        @objc fileprivate func _dismiss() {
            dismissCallback?()
        }
    }
}

public extension ChatMenu.ActionSheet {
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        _layoutViews()
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        _setupViews()
        _setupGestureRecognizer()
    }
}

fileprivate extension ChatMenu.ActionSheet {
    var _expectHeight: CGFloat {
        let offset = _contentViewHeightForCancel > 0 && _contentViewHeightForNormal > 0 ? actionSheetVerticalOffset : 0
        return _contentViewHeightForNormal + _contentViewHeightForCancel + offset
    }

    var _contentViewHeightForNormal: CGFloat {
        let count = _normalActionItems.count
        guard count > 0 else { return 0 }
        return CGFloat(count) * actionSheetItemHeight + CGFloat(count - 1) * 0.5
    }

    var _contentViewHeightForCancel: CGFloat {
        let count = _cancelActionItems.count
        guard count > 0 else { return 0 }
        return CGFloat(count) * actionSheetItemHeight + CGFloat(count - 1) * 0.5
    }

    func _setupGestureRecognizer() {
        let panGR = UIPanGestureRecognizer(target: self, action: #selector(ChatMenu.ActionSheet._listenFor(panGestureReconizer:)))
        view.addGestureRecognizer(panGR)
    }

    func _setupViews() {
        view.backgroundColor = UIColor.clear
        view.addSubview(_contentViewForNormal)
        view.addSubview(_contentViewForCancel)
        _contentViewForNormal.addSubview(_blurViewForNormal)
        _contentViewForCancel.addSubview(_blurViewForCancel)
        _normalActionItems.forEach {
            $0.addTarget(self, action: #selector(ChatMenu.ActionSheet._dismiss), for: .touchUpInside)
            _contentViewForNormal.addSubview($0)
        }
        _cancelActionItems.forEach {
            $0.addTarget(self, action: #selector(ChatMenu.ActionSheet._dismiss), for: .touchUpInside)
            _contentViewForCancel.addSubview($0)
        }
    }

    func _layoutViews() {
        _contentViewForNormal.frame = CGRect(x: 0, y: 0, width: view.bounds.width, height: _contentViewHeightForNormal)
        _contentViewForCancel.frame = CGRect(x: 0, y: _contentViewForNormal.frame.maxY + actionSheetVerticalOffset, width: view.bounds.width, height: _contentViewHeightForCancel)

        _blurViewForNormal.frame = _contentViewForNormal.bounds
        _normalActionItems.enumerated().forEach { index, view in
            view.frame = CGRect(x: 0, y: CGFloat(index) * (actionSheetItemHeight + 0.5), width: self.view.bounds.width, height: actionSheetItemHeight)
        }
        _blurViewForCancel.frame = _contentViewForCancel.bounds
        _cancelActionItems.enumerated().forEach { index, view in
            view.frame = CGRect(x: 0, y: CGFloat(index) * (actionSheetItemHeight + 0.5), width: self.view.bounds.width, height: actionSheetItemHeight)
        }
    }
}

public extension ChatMenu.ActionSheet {
    func show(from viewController: UIViewController) {
        let height = _expectHeight
        let expireY = viewController.view.bounds.height - actionSheetVerticalOffset - height
        view.frame = CGRect(x: actionSheetHorizontalOffset, y: viewController.view.bounds.height, width: viewController.view.bounds.width - 2 * actionSheetHorizontalOffset, height: height)
        viewController.addChildViewController(self)
        viewController.view.addSubview(view)
        UIView.animate(withDuration: 0.25) {
            self.view.frame.origin.y = expireY
        }
    }

    func hide() {
        guard let superview = view.superview else { return }
        UIView.animate(withDuration: 0.25, animations: {
            self.view.frame.origin.y = superview.bounds.height
        }) { _ in
            self.view.removeFromSuperview()
        }
    }
}

public extension ChatMenu.ActionSheet {
    struct Action {
        public let style: ActionStyle
        public let title: String
        public let tintColor: UIColor
        public let action: () -> ()

        public init(style: ActionStyle = .normal, title: String, tintColor: UIColor, action: @escaping () -> ()) {
            self.style = style
            self.title = title
            self.tintColor = tintColor
            self.action = action
        }
    }

    enum ActionStyle {
        case normal
        case cancel
    }
}

fileprivate extension ChatMenu.ActionSheet {
    fileprivate final class _ActionItem: UIButton {
        fileprivate let _action: Action
        init(action: Action) {
            _action = action
            super.init(frame: .zero)
            backgroundColor = UIColor.white.withAlphaComponent(0.9)
            setTitle(_action.title, for: .normal)
            setTitleColor(_action.tintColor, for: .normal)
            titleLabel?.font = action.style == .normal ? actionSheetItemFontForNormal : actionSheetItemFontForCancel
            self.autoresizingMask = .flexibleWidth
            addTarget(self, action: #selector(_ActionItem.doAction), for: .touchUpInside)
            addTarget(self, action: #selector(_ActionItem.switchToActive), for: .touchDown)
        }

        required init?(coder aDecoder: NSCoder) {
            fatalError("init(coder:) has not been implemented")
        }

        @objc func doAction() {
            _action.action()
            switchToUnActive()
        }

        @objc func switchToActive() {
            backgroundColor = UIColor.white.withAlphaComponent(0.6)
        }

        func switchToUnActive() {
            backgroundColor = UIColor.white.withAlphaComponent(0.9)
        }
    }
}

// MARK: - Controller
public extension ChatMenu {
    final class Controller: UIViewController {
        fileprivate var _bubbleControllerConfig: BubbleControllerConfig!
        fileprivate var _actionSheetConfig: ActionSheetConfig!

        public var dismissCallback: (() -> ())?
        public var didCompletedDismissCallback: (() -> ())?

        public init(bubbleControllerConfig: BubbleControllerConfig,
                    actionSheetConfig: ActionSheetConfig) {
            super.init(nibName: nil, bundle: nil)
            _bubbleControllerConfig = bubbleControllerConfig
            _actionSheetConfig = actionSheetConfig
            modalPresentationStyle = .overCurrentContext
            modalTransitionStyle = .crossDissolve

            view.backgroundColor = UIColor.clear
            view.addSubview(_backgroundView)
        }

        override init(nibName nibNameOrNil: String?, bundle nibBundleOrNil: Bundle?) {
            super.init(nibName: nibNameOrNil, bundle: nibBundleOrNil)
        }

        required public init?(coder aDecoder: NSCoder) {
            fatalError("init(coder:) has not been implemented")
        }

        // Views
        fileprivate lazy var _backgroundView: UIButton = {
            let button = UIButton()
            button.backgroundColor = UIColor.black.withAlphaComponent(0.4)
            button.addTarget(self, action: #selector(Controller._dismiss), for: .touchUpInside)
            return button
        }()

        // Controls
        fileprivate lazy var _BubbleController: BubbleController = {
            let bubbleController = BubbleController(direction: self._bubbleControllerConfig.direction,
                                                    items: self._bubbleControllerConfig.items,
                                                    bubbleView: self._bubbleControllerConfig.bubbleView)
            bubbleController.dismissCallback = { [weak self] in
                self?._dismiss()
            }
            return bubbleController
        }()

        fileprivate lazy var _actionSheet: ActionSheet = {
            let actionSheet = ActionSheet(actions: self._actionSheetConfig.actions)
            actionSheet.dismissCallback = { [weak self] in
                self?._dismiss()
            }
            return actionSheet
        }()

        // Dismiss
        @objc fileprivate func _dismiss() {
            _actionSheet.hide()
            dismiss(animated: true, completion: didCompletedDismissCallback)
            dismissCallback?()
        }
    }
}

public extension ChatMenu.Controller {
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        _setupBubbleSnapshotView(bubbleView: _bubbleControllerConfig.bubbleView)
        _BubbleController.show(from: self)
        _actionSheet.show(from: self)
    }

    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        _backgroundView.frame = view.bounds
    }

    override func viewWillTransition(to size: CGSize, with coordinator: UIViewControllerTransitionCoordinator) {
        _dismiss()
    }
}

fileprivate extension ChatMenu.Controller {
    func _setupBubbleSnapshotView(bubbleView: UIView) {
        if let bubbleSuperview = bubbleView.superview {
            guard let bubbleSnapshotView = bubbleView.snapshotView(afterScreenUpdates: false) else { return }
            let frame = bubbleSuperview.convert(bubbleView.frame, to: view)
            bubbleSnapshotView.frame = frame
            bubbleSnapshotView.isUserInteractionEnabled = false
            if _bubbleControllerConfig.direction == .right {
                bubbleSnapshotView.autoresizingMask = .flexibleLeftMargin
            }
            view.addSubview(bubbleSnapshotView)
        }
    }
}

// MARK: - ScaleForActivatedButton
fileprivate class _ScaleForActivatedButton: UIButton {
    let _scale: CGFloat

    fileprivate var _isActivated: Bool = false {
        didSet {
            guard oldValue != _isActivated else { return }
            if _isActivated {
                UIView.animate(withDuration: 0.25, delay: 0, usingSpringWithDamping: 0.25, initialSpringVelocity: 5, options: .curveEaseInOut, animations: {
                    self.transform = CGAffineTransform(scaleX: self._scale, y: self._scale)
                }, completion: nil)
            } else {
                UIView.animate(withDuration: 0.25, delay: 0, usingSpringWithDamping: 0.25, initialSpringVelocity: 5, options: .curveEaseInOut, animations: {
                    self.transform = CGAffineTransform.identity
                }, completion: nil)
            }
        }
    }

    init(frame: CGRect, scale: CGFloat) {
        _scale = scale
        super.init(frame: frame)
        _setupControlEvent()
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

fileprivate extension _ScaleForActivatedButton {
    @objc fileprivate func _switchToNormal() {
        _isActivated = false
    }

    @objc fileprivate func _switchToActivated() {
        _isActivated = true
    }

    fileprivate func _setupControlEvent() {
        addTarget(self, action: #selector(_ScaleForActivatedButton._switchToNormal), for: .touchUpInside)
        addTarget(self, action: #selector(_ScaleForActivatedButton._switchToNormal), for: .touchDragOutside)
        addTarget(self, action: #selector(_ScaleForActivatedButton._switchToActivated), for: .touchDown)
        addTarget(self, action: #selector(_ScaleForActivatedButton._switchToActivated), for: .touchDragInside)
    }
}

// MARK: - UI
fileprivate let menuViewHeight: CGFloat = 60
fileprivate let menuBackgroundViewHeight: CGFloat = 46
fileprivate let menuLittleBubbleSize = CGSize(width: 17, height: 22)
fileprivate let menuItemOffset: CGFloat = min(20 * (UIScreen.main.bounds.width / 414), 20)
fileprivate let menuItemSize = CGSize(width: 30, height: 30)
fileprivate let menuVerticalOffset: CGFloat = 4
fileprivate let menuHorizontalOffset: CGFloat = 20

fileprivate let actionSheetCorners: CGFloat = 12
fileprivate let actionSheetItemHeight: CGFloat = 57
fileprivate let actionSheetHorizontalOffset: CGFloat = 10
fileprivate let actionSheetVerticalOffset: CGFloat = 8
fileprivate let actionSheetItemFontForNormal = UIFont.systemFont(ofSize: 20)
fileprivate let actionSheetItemFontForCancel = UIFont.boldSystemFont(ofSize: 20)
