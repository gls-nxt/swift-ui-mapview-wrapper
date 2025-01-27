//
//  ViewMapAnnotation.swift
//  Map
//
//  Created by Paul Kraft on 23.04.22.
//

#if !os(watchOS)

import MapKit
import SwiftUI

public struct ViewMapAnnotation<Content: View, ClusterContent: View>: MapAnnotation {

    // MARK: Nested Types

    private class Annotation: NSObject, MKAnnotation {

        // MARK: Stored Properties

        let coordinate: CLLocationCoordinate2D
        let title: String?
        let subtitle: String?

        // MARK: Initialization

        init(coordinate: CLLocationCoordinate2D, title: String?, subtitle: String?) {
            self.coordinate = coordinate
            self.title = title
            self.subtitle = subtitle
        }

    }

    // MARK: Static Functions

    public static func registerView(on mapView: MKMapView) {
        mapView.register(MKMapAnnotationView<Content, ClusterContent>.self, forAnnotationViewWithReuseIdentifier: reuseIdentifier)
    }

    // MARK: Stored Properties

    public let annotation: MKAnnotation
    let content: Content
    let selectedContent: Content
    let clusterContent: (Int) -> ClusterContent?
    let clusteringIdentifier: String?

    // MARK: Initialization

    public init(
        coordinate: CLLocationCoordinate2D,
        title: String? = nil,
        subtitle: String? = nil,
        clusteringIdentifier: String? = nil,
        @ViewBuilder content: () -> Content,
        @ViewBuilder selectedContent: () -> Content? = { nil },
        @ViewBuilder clusterContent: @escaping (Int) -> ClusterContent? = { _ in nil }
    ) {
        self.annotation = Annotation(coordinate: coordinate, title: title, subtitle: subtitle)
        self.content = content()
        self.selectedContent = selectedContent() ?? content()
        self.clusterContent = clusterContent
        self.clusteringIdentifier = clusteringIdentifier
    }

    public init(
        annotation: MKAnnotation,
        clusteringIdentifier: String? = nil,
        @ViewBuilder content: () -> Content,
        @ViewBuilder selectedContent: () -> Content? = { nil },
        @ViewBuilder clusterContent: @escaping (Int) -> ClusterContent? = { _ in nil }
    ) {
        self.annotation = annotation
        self.clusteringIdentifier = clusteringIdentifier
        self.content = content()
        self.selectedContent = selectedContent() ?? content()
        self.clusterContent = clusterContent
    }

    // MARK: Methods

    public func view(for mapView: MKMapView) -> MKAnnotationView? {
        let view = mapView.dequeueReusableAnnotationView(
            withIdentifier: Self.reuseIdentifier,
            for: annotation
        ) as? MKMapAnnotationView<Content, ClusterContent>

        view?.setup(for: self)
        return view
    }
    
    public func clusterView(for mapView: MKMapView, clusterAnnotation: MKClusterAnnotation) -> MKAnnotationView? {
        guard let clusterContent = clusterContent(clusterAnnotation.memberAnnotations.count) else {
            return nil
        }
        
        return MKMapClusterView(clusterContent: clusterContent,
                                clusterAnnotation: clusterAnnotation)
    }

}

#endif
