//
//  DebugLocationView.swift
//  EstacioneAqui
//


#if DEBUG

import SwiftUI
import MapKit

struct DebugLocationView: View {

    private enum Discovery: Equatable {
        case idle
        case checking
        case inside(String)
        case outside
        case failed(String)
    }

    private let service: AreaServicing = AreaService()

    @State private var override = DebugLocationOverride.shared
    @State private var locator = DebugAreaLocator()
    @State private var areas: [ParkingArea] = []
    @State private var picked: CLLocationCoordinate2D?
    @State private var camera: MapCameraPosition = .automatic
    @State private var latitudeText = ""
    @State private var longitudeText = ""
    @State private var discovery: Discovery = .idle
    @State private var isNamingPlace = false
    @State private var newPlaceName = ""

    @Environment(\.dismiss) private var dismiss

    private var pickedKey: String {
        guard let picked else { return "" }
        return "\(picked.latitude),\(picked.longitude)"
    }

    var body: some View {
        List {
            statusSection
            areasSection
            mapSection
            coordinateSection
            placesSection
        }
        .navigationTitle(Text(verbatim: "Localização (debug)"))
        .navigationBarTitleDisplayMode(.inline)
        .onAppear(perform: seed)
        .task {
            await loadAreas()
        }
        .task(id: pickedKey) {
            await validate()
        }
        .alert(Text(verbatim: "Salvar lugar"), isPresented: $isNamingPlace) {
            TextField(text: $newPlaceName) { Text(verbatim: "Nome") }
            Button(role: .cancel) { } label: { Text(verbatim: "Cancelar") }
            Button {
                if let picked, !newPlaceName.isEmpty {
                    override.save(name: newPlaceName, coordinate: picked)
                }
                newPlaceName = ""
            } label: {
                Text(verbatim: "Salvar")
            }
        }
    }


    private var statusSection: some View {
        Section {
            if let active = override.coordinate {
                LabeledContent {
                    Text(verbatim: format(active))
                        .monospacedDigit()
                } label: {
                    Label {
                        Text(verbatim: "Fixada")
                    } icon: {
                        Image(systemName: "location.fill.viewfinder")
                    }
                }

                if !isSame(active, DebugLocationOverride.blumenauCentro) {
                    Button {
                        apply(DebugLocationOverride.blumenauCentro)
                        override.reset()
                    } label: {
                        Text(verbatim: "Voltar ao centro de Blumenau")
                    }
                }

                Button(role: .destructive) {
                    override.clear()
                } label: {
                    Text(verbatim: "Voltar ao GPS real")
                }
            } else {
                Button {
                    apply(DebugLocationOverride.blumenauCentro)
                    override.reset()
                } label: {
                    Text(verbatim: "Fixar no centro de Blumenau")
                }

                Label {
                    Text(verbatim: "Usando o GPS real")
                } icon: {
                    Image(systemName: "location.fill")
                }
                .foregroundStyle(.secondary)
            }
        } footer: {
            Text(verbatim: "A escolha vale para todo o app e sobrevive ao relançamento.")
        }
    }


    @ViewBuilder
    private var areasSection: some View {
        Section {
            if areas.isEmpty {
                HStack(spacing: 8) {
                    ProgressView()
                    Text(verbatim: "Carregando áreas…")
                        .foregroundStyle(.secondary)
                }
            } else {
                ForEach(areas) { area in
                    areaRow(area)
                }
            }
        } header: {
            HStack {
                Text(verbatim: "Áreas azuis")
                Spacer()
                if locator.isLocatingAll {
                    ProgressView()
                } else if areas.contains(where: { locator.coordinate(for: $0.id) == nil }) {
                    Button {
                        Task { await locator.locateMissing(in: areas) }
                    } label: {
                        Text(verbatim: "Localizar")
                    }
                }
            }
        } footer: {
            Text(verbatim: "O backend não devolve as coordenadas das áreas. "
                + "Cada ponto abaixo foi encontrado por busca no mapa e confirmado "
                + "no /areas/discover — escolher um ponto na mão também aprende.")
        }
    }

    @ViewBuilder
    private func areaRow(_ area: ParkingArea) -> some View {
        let coordinate = locator.coordinate(for: area.id)

        Button {
            guard let coordinate else { return }
            apply(coordinate)
            override.use(coordinate)
        } label: {
            HStack(spacing: 12) {
                areaStatusIcon(for: area)
                    .frame(width: 20)

                VStack(alignment: .leading, spacing: 2) {
                    Text(verbatim: area.name)
                        .foregroundStyle(coordinate == nil ? .secondary : .primary)
                    Text(verbatim: "\(area.city) · \(area.pricePerHour.brl)/h")
                        .font(.caption)
                        .foregroundStyle(.secondary)
                }

                Spacer()

                if override.coordinate.map({ isSame($0, coordinate) }) == true {
                    Image(systemName: "location.fill.viewfinder")
                        .foregroundStyle(Color.primaryBlue)
                }
            }
        }
        .buttonStyle(.plain)
        .disabled(coordinate == nil)
        .swipeActions {
            if coordinate != nil {
                Button(role: .destructive) {
                    locator.forget(areaId: area.id)
                } label: {
                    Text(verbatim: "Esquecer")
                }
            } else {
                Button {
                    Task { await locator.locate(area) }
                } label: {
                    Text(verbatim: "Localizar")
                }
            }
        }
    }

    @ViewBuilder
    private func areaStatusIcon(for area: ParkingArea) -> some View {
        switch locator.states[area.id] ?? .unknown {
        case .located:
            Image(systemName: "mappin.circle.fill")
                .foregroundStyle(.green)
        case .locating:
            ProgressView()
        case .notFound:
            Image(systemName: "questionmark.circle")
                .foregroundStyle(.orange)
        case .unknown:
            Image(systemName: "circle.dotted")
                .foregroundStyle(.tertiary)
        }
    }


    private var mapSection: some View {
        Section {
            MapReader { proxy in
                Map(position: $camera) {
                    if let picked {
                        Marker("", coordinate: picked)
                            .tint(Color.primaryBlue)
                    }
                }
                .frame(height: 260)
                .onTapGesture { point in
                    guard let coordinate = proxy.convert(point, from: .local) else { return }
                    apply(coordinate)
                }
                .listRowInsets(EdgeInsets())
            }
        } footer: {
            Text(verbatim: "Toque no mapa para escolher o ponto.")
        }
    }


    private var coordinateSection: some View {
        Section {
            LabeledContent {
                TextField(text: $latitudeText) { Text(verbatim: "-26.9175") }
                    .keyboardType(.numbersAndPunctuation)
                    .multilineTextAlignment(.trailing)
                    .onSubmit(applyTypedCoordinate)
            } label: {
                Text(verbatim: "Latitude")
            }

            LabeledContent {
                TextField(text: $longitudeText) { Text(verbatim: "-49.0716") }
                    .keyboardType(.numbersAndPunctuation)
                    .multilineTextAlignment(.trailing)
                    .onSubmit(applyTypedCoordinate)
            } label: {
                Text(verbatim: "Longitude")
            }

            discoveryRow

            Button {
                guard let picked else { return }
                override.use(picked)
            } label: {
                Text(verbatim: "Usar este ponto")
            }
            .disabled(picked == nil)

            Button {
                isNamingPlace = true
            } label: {
                Text(verbatim: "Salvar como lugar")
            }
            .disabled(picked == nil)
        } header: {
            Text(verbatim: "Ponto escolhido")
        }
    }

    @ViewBuilder
    private var discoveryRow: some View {
        switch discovery {
        case .idle:
            EmptyView()
        case .checking:
            HStack(spacing: 8) {
                ProgressView()
                Text(verbatim: "Consultando o backend…")
                    .foregroundStyle(.secondary)
            }
        case .inside(let name):
            Label {
                Text(verbatim: "Dentro de \(name)")
            } icon: {
                Image(systemName: "checkmark.circle.fill")
            }
            .foregroundStyle(.green)
        case .outside:
            Label {
                Text(verbatim: "Fora de qualquer área azul")
            } icon: {
                Image(systemName: "exclamationmark.triangle.fill")
            }
            .foregroundStyle(.orange)
        case .failed(let message):
            Label {
                Text(verbatim: message)
            } icon: {
                Image(systemName: "xmark.circle.fill")
            }
            .foregroundStyle(.red)
        }
    }


    @ViewBuilder
    private var placesSection: some View {
        if !override.places.isEmpty {
            Section {
                ForEach(override.places) { place in
                    Button {
                        apply(place.coordinate)
                        override.use(place.coordinate)
                    } label: {
                        VStack(alignment: .leading, spacing: 2) {
                            Text(verbatim: place.name)
                            Text(verbatim: format(place.coordinate))
                                .font(.caption)
                                .monospacedDigit()
                                .foregroundStyle(.secondary)
                        }
                    }
                    .buttonStyle(.plain)
                }
                .onDelete { override.remove(atOffsets: $0) }
            } header: {
                Text(verbatim: "Lugares salvos")
            }
        }
    }


    private func seed() {
        let start = override.coordinate ?? override.places.first?.coordinate
        if let start {
            apply(start)
        } else {
            camera = .userLocation(fallback: .automatic)
        }
    }

    private func apply(_ coordinate: CLLocationCoordinate2D) {
        picked = coordinate
        latitudeText = String(coordinate.latitude)
        longitudeText = String(coordinate.longitude)
        camera = .region(
            MKCoordinateRegion(
                center: coordinate,
                span: MKCoordinateSpan(latitudeDelta: 0.01, longitudeDelta: 0.01)
            )
        )
    }

    private func applyTypedCoordinate() {
        guard let latitude = Double(latitudeText), let longitude = Double(longitudeText),
              CLLocationCoordinate2DIsValid(.init(latitude: latitude, longitude: longitude))
        else { return }
        apply(.init(latitude: latitude, longitude: longitude))
    }

    private func validate() async {
        guard let picked else {
            discovery = .idle
            return
        }
        discovery = .checking
        switch await service.discover(
            latitude: picked.latitude,
            longitude: picked.longitude
        ) {
        case .success(let area):
            guard let area else {
                discovery = .outside
                return
            }
            discovery = .inside(area.name)
            locator.remember(picked, areaId: area.id)
        case .error(let failure):
            discovery = .failed(String(describing: failure))
        }
    }

    private func loadAreas() async {
        guard areas.isEmpty else { return }
        if case .success(let response) = await service.areas() {
            areas = response.filter(\.active).map { $0.toDomain() }
        }
    }

    private func isSame(_ lhs: CLLocationCoordinate2D, _ rhs: CLLocationCoordinate2D?) -> Bool {
        guard let rhs else { return false }
        return lhs.latitude == rhs.latitude && lhs.longitude == rhs.longitude
    }

    private func format(_ coordinate: CLLocationCoordinate2D) -> String {
        String(format: "%.5f, %.5f", coordinate.latitude, coordinate.longitude)
    }
}

#Preview {
    NavigationStack {
        DebugLocationView()
    }
}

#endif
