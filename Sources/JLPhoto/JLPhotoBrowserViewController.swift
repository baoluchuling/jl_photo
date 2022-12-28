//
//  JLPhotoBrowser.swift
//  JanLi
//
//  Created by admin on 2021/10/22.
//  Copyright © 2021 com.baoluchuling.janli. All rights reserved.
//

import UIKit
import Photos

public class JLPhotoBrowserViewController: UIViewController, UICollectionViewDelegate {
    
    public var cancel: (() -> Void)?
    public var complete: (([JLAsset]) -> Void)?
    
    static let JLPhotoItemCollectionPhotoCellKey: String = String(describing: JLPhotoItemCollectionPhotoCell.self)
    static let JLPhotoItemCollectionCameraCellKey: String = String(describing: JLPhotoItemCollectionCameraCell.self)
    
    lazy var collectionView: UICollectionView = { [weak self] in
                
        let item = NSCollectionLayoutItem(layoutSize: NSCollectionLayoutSize(widthDimension: .fractionalWidth(0.25), heightDimension: .fractionalWidth(0.25)))
        item.contentInsets = NSDirectionalEdgeInsets(top: 2, leading: 2, bottom: 2, trailing: 2)
        
        let group = NSCollectionLayoutGroup.horizontal(layoutSize: NSCollectionLayoutSize(
                                                widthDimension: .fractionalWidth(1.0),
                                                        heightDimension: .fractionalWidth(0.25)),
                                                       subitems: [item])
        
        let section = NSCollectionLayoutSection(group: group)
        section.contentInsets = NSDirectionalEdgeInsets(top: 0, leading: 2, bottom:0, trailing: 2)
        
        // 配置布局
        let layout = UICollectionViewCompositionalLayout(section: section)
        
        let collectionView = UICollectionView(frame: CGRect(x: 0, y: 0, width: UIScreen.main.bounds.width, height: UIScreen.main.bounds.height), collectionViewLayout: layout)
        collectionView.backgroundColor = UIColor.white
        collectionView.delegate = self
        
        collectionView.register(JLPhotoItemCollectionPhotoCell.self, forCellWithReuseIdentifier: JLPhotoBrowserViewController.JLPhotoItemCollectionPhotoCellKey)
        collectionView.register(JLPhotoItemCollectionCameraCell.self, forCellWithReuseIdentifier: JLPhotoBrowserViewController.JLPhotoItemCollectionCameraCellKey)
        
        return collectionView
    }()
    
    lazy var diffDataSource: UICollectionViewDiffableDataSource<String, JLAsset> = {
        return UICollectionViewDiffableDataSource<String, JLAsset>(collectionView: collectionView) { [weak self] collectionView, indexPath, item in
            
            if (indexPath.section == 0 && indexPath.item == 0) {
                let cell: JLPhotoItemCollectionCameraCell = collectionView.dequeueReusableCell(withReuseIdentifier: JLPhotoBrowserViewController.JLPhotoItemCollectionCameraCellKey, for: indexPath) as! JLPhotoItemCollectionCameraCell
                return cell
            } else {
                let cell: JLPhotoItemCollectionPhotoCell = collectionView.dequeueReusableCell(withReuseIdentifier: JLPhotoBrowserViewController.JLPhotoItemCollectionPhotoCellKey, for: indexPath) as! JLPhotoItemCollectionPhotoCell
                cell.updateInfo(item) { [weak self] status in
                    
                    self?.select.removeAll(where: { old in
                        return old == item
                    })
                    
                    if status {
                        self?.select.append(item)
                    }
                    
                    let selectCount = self?.select.count ?? 0
                    let selectEnable = selectCount > 0
                    
                    self?.updateRightBarButton(with: "使用\(selectEnable ? "(\(selectCount))" : "")", isEnabled: selectEnable)
                }
                return cell
            }
        }
    }()
    
    public func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        if (indexPath.section == 0 && indexPath.item == 0) {
            let camera = JLCameraViewController()
            camera.complete = onComplete(assets:)
            camera.cancel = cancel
            
            let navVC = UINavigationController(rootViewController: camera)
            navVC.modalPresentationStyle = .overFullScreen
            
            self.present(navVC, animated: true)
        }
    }
    
    var select: [JLAsset] = []
    
    struct SectionInfo {
        var title: String?
        var items: [JLAsset]?
    }
    
    var sections: [SectionInfo] = []
    
    func makeData() -> [SectionInfo] {
        
        let opt = PHFetchOptions()
        
        let res = PHAsset.fetchAssets(with: .image, options: opt)
        
        var arr: [JLAsset] = []
        res.enumerateObjects { asset, index, pointer in
            arr.append(JLAsset(asset: asset))
        }
                
        return [
            SectionInfo(title: "0", items: arr),
        ]
    }
    
    var completeBarButton: UIBarButtonItem?
    
    public override func viewDidLoad() {
        super.viewDidLoad()
                
        self.navigationController?.navigationBar.backgroundColor = UIColor.white
        self.navigationController?.navigationBar.isTranslucent = false;
        self.navigationController?.isNavigationBarHidden = false
        self.navigationController?.navigationBar.setBackgroundImage(UIImage(), for: .default)
        self.navigationController?.navigationBar.shadowImage = UIImage()
        
        self.navigationItem.title = "图片选择"
        
        self.view.backgroundColor = UIColor.white
        
        self.updateLeftBarButton()
        self.updateRightBarButton(with: "使用", isEnabled: false)
        
        self.view.addSubview(self.collectionView)
        self.collectionView.dataSource = self.diffDataSource
        self.collectionView.snp.makeConstraints({ maker in
            maker.edges.equalToSuperview()
        })
        
        requestAuthorization {
            DispatchQueue.global().async {
                self.sections = self.makeData()

                var snapchat = self.diffDataSource.snapshot()
                snapchat.appendSections(self.sections.map({ $0.title ?? "--"}))
                self.sections.forEach { section in
                    snapchat.appendItems(section.items ?? [], toSection: section.title ?? "")
                }
                self.diffDataSource.apply(snapchat)
            }
        }
    }
    
    func requestAuthorization(_ handle: @escaping () -> Void) -> Void {
        switch PHPhotoLibrary.authorizationStatus() {
            case .notDetermined:
                PHPhotoLibrary.requestAuthorization { [weak self] status in
                    self?.requestAuthorization(handle)
                }
                break
            case .restricted, .denied:
                break
            case .authorized, .limited:
                handle()
                break
            @unknown default:
                fatalError()
            }
    }
    
    @objc func onClickClose() {
        
        maybePop()
        
        guard self.cancel != nil else {
            return
        }
        self.cancel!()
    }
    
    @objc func onClickComplete() {
        self.onComplete(assets: select)
    }
    
    func onComplete(assets: [JLAsset]) {
        maybePop()
        
        guard self.complete != nil else {
            return
        }
        self.complete!(assets)
    }

    
    func updateLeftBarButton() -> Void {
        let leftBarButton = UIBarButtonItem(image: UIImage(systemName: "xmark"), style: .plain, target: self, action: #selector(onClickClose))
        leftBarButton.tintColor = UIColor.black
        self.navigationItem.leftBarButtonItem = leftBarButton
        
    }
    
    func updateRightBarButton(with title: String, isEnabled: Bool) -> Void {
        let completeBarButton = UIBarButtonItem(title: title, style: .done, target: self, action: #selector(onClickComplete))
        completeBarButton.isEnabled = isEnabled
        completeBarButton.tintColor = isEnabled ? UIColor.systemBlue : UIColor.gray
        
        self.navigationItem.rightBarButtonItem = completeBarButton
    }
}
