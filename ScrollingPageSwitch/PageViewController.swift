//
//  PageViewController.swift
//  ScrollingPageSwitch
//
//  Created by Arifin Firdaus on 08/10/20.
//  Copyright © 2020 Arifin Firdaus. All rights reserved.
//

import UIKit

class PageViewController: UIPageViewController {
    let texts = MockTextsProvider.provideTexts()
    private var orderedViewControllers = [UIViewController]()
    private var pendingPage: Int?
    private var currentPage: Int = 0
    
    enum PageMode {
        case paging
        case scrolling
    }
    
    var isPagingMode = true
    var pageMode: PageMode = .paging
    
    override func viewDidLoad() {
        super.viewDidLoad()
        dataSource = self
        delegate = self
        orderedViewControllers = makeSinglePageViewControllers()
        setFirstViewControllerIfNeeded(at: currentPage)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        updateNavigationBarTitle()
    }
    
    @IBAction func toggle(_ sender: UIBarButtonItem) {
        togglePageModeValue()
        
        if pageMode == .scrolling {
            activateScrollingMode()
        }
        if pageMode == .paging {
            activatePagingMode()
        }
    }
    
    private func togglePageModeValue() {
        isPagingMode = !isPagingMode
        pageMode = isPagingMode
            ? .paging
            : .scrolling
        print(pageMode)
    }
    
    private func activatePagingMode() {
        orderedViewControllers = makeSinglePageViewControllers()
        print(orderedViewControllers.count)
        setFirstViewControllerIfNeeded(at: currentPage)
    }
    
    private func activateScrollingMode() {
        self.orderedViewControllers = [makeViewControllerForScrollingMode()]
        setFirstViewControllerIfNeeded()
    }
    
    func makeViewControllerForScrollingMode() -> UIViewController {
        let clonedTexts = texts
        let joinedText = clonedTexts.joined(separator: "\n\n") // PR
        let viewController = makeSinglePageViewController(withText: joinedText)
        let page = 1
        viewController.view.tag = page
        return viewController
    }
    
    func makeSinglePageViewControllers() -> [UIViewController] {
        var singlePageViewControllers = [UIViewController]()
        for (page, text) in texts.enumerated() {
            let viewController = makeSinglePageViewController(withText: text)
            viewController.view.tag = page
            singlePageViewControllers.append(viewController)
        }
        return singlePageViewControllers
    }
    
    func makeSinglePageViewController(withText text: String) -> UIViewController {
        let storyboard = UIStoryboard(name: "Main", bundle: Bundle.main)
        let viewController = storyboard.instantiateViewController(identifier: "SinglePageViewController") as! SinglePageViewController
        viewController.text = text
        return viewController
    }
    
    func setFirstViewControllerIfNeeded(at page: Int) {
        let firstViewController = orderedViewControllers[page]
        setViewControllers([firstViewController], direction: .reverse, animated: false) { isFinished in
            if isFinished {
                if self.pageMode == .scrolling {
                    self.updateNavigationBarTitleForScrollingMode()
                }
                if self.pageMode == .paging {
                    self.updateNavigationBarTitle()
                }
            }
        }
    }
    
    func setFirstViewControllerIfNeeded() {
        if let firstViewController = orderedViewControllers.first {
            setViewControllers([firstViewController], direction: .reverse, animated: false) { isFinished in
                if isFinished {
                    if self.pageMode == .scrolling {
                        self.updateNavigationBarTitleForScrollingMode()
                    }
                    if self.pageMode == .paging {
                        self.updateNavigationBarTitle()
                    }
                }
            }
        }
    }
}


// MARK: - UIPageViewControllerDataSource

extension PageViewController: UIPageViewControllerDataSource {
    
    func pageViewController(_ pageViewController: UIPageViewController, viewControllerBefore viewController: UIViewController) -> UIViewController? {
        guard let viewControllerIndex = orderedViewControllers.firstIndex(of: viewController) else {
            return nil
        }
        let previousIndex = viewControllerIndex - 1
        
        guard previousIndex >= 0 else { return nil }
        guard orderedViewControllers.count > previousIndex else { return nil }
        
        return orderedViewControllers[previousIndex]
    }
    
    func pageViewController(_ pageViewController: UIPageViewController, viewControllerAfter viewController: UIViewController) -> UIViewController? {
        guard let viewControllerIndex = orderedViewControllers.firstIndex(of: viewController) else {
            return nil
        }
        let nextIndex = viewControllerIndex + 1
        let orderedViewControllersCount = orderedViewControllers.count
        
        guard orderedViewControllersCount != nextIndex else { return nil }
        guard orderedViewControllersCount > nextIndex else { return nil }
        
        return orderedViewControllers[nextIndex]
    }
    
}


// MARK: - UIPageViewControllerDelegate

extension PageViewController: UIPageViewControllerDelegate {
    
    func pageViewController(_ pageViewController: UIPageViewController, willTransitionTo pendingViewControllers: [UIViewController]) {
        pendingPage = orderedViewControllers.firstIndex(of: pendingViewControllers.first!)
    }
    
    func pageViewController(_ pageViewController: UIPageViewController, didFinishAnimating finished: Bool, previousViewControllers: [UIViewController], transitionCompleted completed: Bool) {
        if completed {
            guard completed, let page = pendingPage else {
                return
            }
            self.currentPage = page
            self.updateNavigationBarTitle()
        }
    }
    
    private func updateNavigationBarTitle() {
        let title = makePageTitle()
        self.title = title
    }
    
    private func makePageTitle() -> String {
        let maxPage = self.orderedViewControllers.count
        let title = "\(currentPage + 1) of \(maxPage)"
        return title
    }
    
    private func updateNavigationBarTitleForScrollingMode() {
        self.title = makePageTitle(currentPage: 1, maxPage: 1)
    }
    
    private func makePageTitle(currentPage: Int, maxPage: Int) -> String {
        let title = "\(currentPage) of \(maxPage)"
        return title
    }
    
}

