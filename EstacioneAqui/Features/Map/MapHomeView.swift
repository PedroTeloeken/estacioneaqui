//
//  MapHomeView.swift
//  EstacioneAqui
//


import SwiftUI
import MapKit

struct MapHomeView: View {
    
    @State private var locationService = LocationService()
    @State private var viewModel = MapViewModel()
    @State private var camera: MapCameraPosition = .userLocation(fallback: .automatic)
    @State private var startParkingArea: ParkingArea?
    @State private var carRoute = CarRouteViewModel()

    @Environment(ActiveSessionStore.self) private var sessionStore

    #if DEBUG
    @State private var debugOverride = DebugLocationOverride.shared

    private var debugOverrideKey: String {
        guard let coordinate = debugOverride.coordinate else { return "" }
        return "\(coordinate.latitude),\(coordinate.longitude)"
    }
    #endif

    var body: some View {
        Map(position: $camera) {
            if let zone = visibleZone {
                MapCircle(center: zone.center, radius: zone.radius)
                    .foregroundStyle(Color.primaryBlue.opacity(0.20))
                    .stroke(Color.primaryBlue.opacity(0.85), lineWidth: 2)
            }

            #if DEBUG
            if let simulated = debugOverride.coordinate {
                Annotation("", coordinate: simulated, anchor: .center) {
                    SimulatedUserDot()
                }
                .annotationTitles(.hidden)
            } else {
                UserAnnotation()
            }
            #else
            UserAnnotation()
            #endif

            if sessionStore.session == nil,
               let area = viewModel.discoveredArea,
               let coordinate = locationService.lastLocation?.coordinate {
                Annotation(area.name, coordinate: coordinate, anchor: .bottom) {
                    AreaPin(
                        priceLabel: area.pricePerHour.brl,
                        isSelected: viewModel.selectedArea?.id == area.id
                    )
                    .onTapGesture {
                        viewModel.selectedArea = area
                    }
                    .offset(y: -26)
                }
                .annotationTitles(.hidden)
            }

            if let carCoordinate {
                Annotation("my_car", coordinate: carCoordinate, anchor: .bottom) {
                    CarPin(isSelected: carRoute.isCarSelected)
                        .onTapGesture {
                            viewModel.selectedArea = nil
                            carRoute.selectCar()
                        }
                        .offset(y: -26)
                }
                .annotationTitles(.hidden)
            }

            if let route = carRoute.route {
                MapPolyline(route.polyline)
                    .stroke(
                        Color.primaryBlue,
                        style: StrokeStyle(lineWidth: 5, lineCap: .round, lineJoin: .round)
                    )
            }
        }
        .mapControls {
            MapUserLocationButton()
            MapCompass()
        }
        .safeAreaInset(edge: .bottom) {
            bottomOverlay
                .padding(.horizontal, 12)
                .padding(.bottom, 6)
                .animation(.easeInOut(duration: 0.25), value: viewModel.selectedArea)
                .animation(.easeInOut(duration: 0.25), value: viewModel.discoveredArea)
                .animation(.easeInOut(duration: 0.25), value: carRoute.isCarSelected)
        }
        .sheet(item: $startParkingArea) { area in
            if let coordinate = locationService.lastLocation?.coordinate {
                StartParkingSheet(area: area, coordinate: coordinate)
            }
        }
        .task {
            locationService.start()
            await viewModel.loadAreas()
        }
        #if DEBUG
        .onChange(of: debugOverrideKey, initial: true) { _, _ in
            guard let simulated = debugOverride.coordinate else {
                camera = .userLocation(fallback: .automatic)
                return
            }
            camera = .region(
                MKCoordinateRegion(
                    center: simulated,
                    latitudinalMeters: 900,
                    longitudinalMeters: 900
                )
            )
        }
        #endif
        .onChange(of: locationService.lastLocation) { _, location in
            guard let location else { return }
            Task {
                await viewModel.discoverIfNeeded(at: location)
            }
        }
        .onChange(of: sessionStore.session) { _, session in
            if session == nil {
                carRoute.clear()
            }
        }
    }

    @ViewBuilder
    private var bottomOverlay: some View {
        if locationService.isAuthorizationDenied {
            LocationDeniedCard()
                .transition(.opacity)
        } else if carRoute.isCarSelected, let session = sessionStore.session {
            CarRouteCard(
                session: session,
                straightLineDistance: straightLineDistanceToCar,
                route: carRoute.route,
                isCalculating: carRoute.isCalculating,
                error: carRoute.error,
                onRoute: { Task { await routeToCar() } },
                onOpenInMaps: openCarInMaps,
                onClearRoute: carRoute.clearRoute,
                onClose: carRoute.clear
            )
            .transition(.opacity)
        } else if let selected = viewModel.selectedArea {
            SelectedAreaCard(
                area: selected,
                availability: availability(for: selected),
                isZoneVisible: viewModel.visibleZoneAreaId == selected.id,
                onClose: { viewModel.selectedArea = nil },
                onPark: { startParkingArea = selected },
                onToggleZone: showZone
            )
            .transition(.opacity)
        } else if sessionStore.session == nil, !viewModel.areas.isEmpty {
            NearbyAreasCard(
                areas: viewModel.areas,
                discoveredAreaId: viewModel.discoveredArea?.id,
                onSelect: { viewModel.selectedArea = $0 }
            )
            .transition(.opacity)
        }
    }

    private func availability(for area: ParkingArea) -> SelectedAreaCard.Availability {
        if sessionStore.session != nil { return .sessionInProgress }
        return area.id == viewModel.discoveredArea?.id ? .available : .outsideArea
    }


    private var visibleZone: ParkingArea.Zone? {
        guard let id = viewModel.visibleZoneAreaId else { return nil }
        return viewModel.areas.first { $0.id == id }?.zone ?? viewModel.selectedArea?.zone
    }

    private func showZone() {
        guard let zone = viewModel.toggleVisibleZone() else { return }

        let span = zone.radius * 2.8
        withAnimation(.easeInOut(duration: 0.35)) {
            camera = .region(
                MKCoordinateRegion(
                    center: zone.center,
                    latitudinalMeters: span,
                    longitudinalMeters: span
                )
            )
        }
    }


    private var carCoordinate: CLLocationCoordinate2D? {
        guard let session = sessionStore.session else { return nil }
        return CLLocationCoordinate2D(latitude: session.latitude, longitude: session.longitude)
    }

    private var straightLineDistanceToCar: CLLocationDistance? {
        guard let session = sessionStore.session,
              let current = locationService.lastLocation
        else { return nil }

        let car = CLLocation(latitude: session.latitude, longitude: session.longitude)
        return current.distance(from: car)
    }

    private func routeToCar() async {
        guard let origin = locationService.lastLocation?.coordinate,
              let carCoordinate
        else { return }

        await carRoute.calculateRoute(from: origin, to: carCoordinate)

        if let route = carRoute.route {
            camera = .rect(route.polyline.boundingMapRect)
        }
    }

    private func openCarInMaps() {
        guard let carCoordinate else { return }

        let item = MKMapItem(
            location: CLLocation(latitude: carCoordinate.latitude, longitude: carCoordinate.longitude),
            address: nil
        )
        item.name = String(localized: "my_car")
        item.openInMaps(launchOptions: [
            MKLaunchOptionsDirectionsModeKey: MKLaunchOptionsDirectionsModeWalking
        ])
    }
}

#if DEBUG
private struct SimulatedUserDot: View {
    var body: some View {
        Circle()
            .fill(Color.primaryBlue)
            .frame(width: 18, height: 18)
            .overlay(Circle().stroke(.white, lineWidth: 3))
            .shadow(color: .black.opacity(0.25), radius: 3, y: 1)
    }
}
#endif

private struct LocationDeniedCard: View {
    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            Label("location_off", systemImage: "location.slash.fill")
                .font(.headline)

            Text("location_permission_prompt")
                .font(.subheadline)
                .foregroundStyle(.secondary)

            Button("open_settings") {
                if let url = URL(string: UIApplication.openSettingsURLString) {
                    UIApplication.shared.open(url)
                }
            }
            .font(.subheadline.weight(.semibold))
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding(20)
        .glassEffect(.regular, in: .rect(cornerRadius: 24))
        .shadow(color: .elevationShadow, radius: 16, y: 6)
    }
}

#Preview {
    MapHomeView()
        .environment(ActiveSessionStore())
}
