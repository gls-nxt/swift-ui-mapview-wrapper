//
//  MKMapAnnotationView.swift
//  Map
//
//  Created by Paul Kraft on 23.04.22.
//

#if !os(watchOS)

import MapKit
import SwiftUI

class MKMapAnnotationView<Content: View, ClusterContent: View>: MKAnnotationView {

    // MARK: Stored Properties

    private var controller: NativeHostingController<Content>?
    private var selectedContent: Content?
    private var notSelectedContent: Content?
    private var viewMapAnnotation: ViewMapAnnotation<Content, ClusterContent>?

    // MARK: Methods

    func setup(for mapAnnotation: ViewMapAnnotation<Content, ClusterContent>) {
        annotation = mapAnnotation.annotation
        self.viewMapAnnotation = mapAnnotation
        self.clusteringIdentifier = mapAnnotation.clusteringIdentifier
        updateContent(for: self.isSelected)
    }
    
    private func updateContent(for selectedState: Bool) {
        guard let contentView = selectedState ? viewMapAnnotation?.selectedContent : viewMapAnnotation?.content else {
            return
        }
        controller?.view.removeFromSuperview()
        let controller = NativeHostingController(rootView: contentView)
        addSubview(controller.view)
        bounds.size = controller.preferredContentSize
        self.controller = controller
    }

    // MARK: Overrides
    override func setSelected(_ selected: Bool, animated: Bool) {
        updateContent(for: selected)
    }

    override func layoutSubviews() {
        super.layoutSubviews()

        if let controller = controller {
            bounds.size = controller.preferredContentSize
        }
    }

    override func prepareForReuse() {
        super.prepareForReuse()

        #if canImport(UIKit)
        controller?.willMove(toParent: nil)
        #endif
        controller?.view.removeFromSuperview()
        controller?.removeFromParent()
        controller = nil
    }
}

class MKMapClusterView<Content, ClusterContent>: MKAnnotationView
where Content: View, ClusterContent: View {
    typealias CustomMKMapAnnotationView = MKMapAnnotationView<Content, ClusterContent>
    
    init(clusterCount: Int, annotation: ViewMapAnnotation<Content, ClusterContent>, clusterAnnotation: MKClusterAnnotation) {
        super.init(annotation: clusterAnnotation, reuseIdentifier: "customClusterReuseIdentifier")
        let content = annotation.clusterContent(clusterCount)
        self.addSubview(UIHostingController.init(rootView: content).view)
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

#endif
