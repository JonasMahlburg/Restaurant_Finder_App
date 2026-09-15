//
//  MapView.swift
//  Restaurant_Finder
//
//  Created by Jonas Mahlburg on 31.08.26.
//
// Finding restaurants in Celle

import MapKit
import SwiftUI

struct MapView: View {
    @State private var position: MapCameraPosition = .automatic
    @State private var restaurants: [MKMapItem] = []
    @State private var currentCity: String = "Celle"
    @State private var searchText: String = ""
    @State private var isSearching: Bool = false
    @State private var showCitySearch: Bool = false
    @State private var showErrorAlert: Bool = false
    @State private var errorMessage: String = ""

    var body: some View {
        ZStack(alignment: .topTrailing) {
            // Karte
            Map(position: $position) {
                ForEach(restaurants, id: \.self) { restaurant in
                    Marker(item: restaurant)
                }
            }
            
            // Floating Button für Städtesuche
            VStack {
                HStack {
                    Spacer()
                    
                    VStack(spacing: 12) {
                        // Stadt-Such-Button
                        Button {
                            showCitySearch = true
                        } label: {
                            Image(systemName: "magnifyingglass.circle.fill")
                                .font(.system(size: 44))
                                .foregroundStyle(.white)
                                .background {
                                    Circle()
                                        .fill(.blue)
                                        .frame(width: 50, height: 50)
                                }
                        }
                        .shadow(radius: 4)
                        
                        // Zurück zu Standard-Stadt Button
                        Button {
                            resetToDefaultCity()
                        } label: {
                            Image(systemName: "location.circle.fill")
                                .font(.system(size: 44))
                                .foregroundStyle(.white)
                                .background {
                                    Circle()
                                        .fill(.green)
                                        .frame(width: 50, height: 50)
                                }
                        }
                        .shadow(radius: 4)
                    }
                    .padding()
                }
                
                Spacer()
                
                // Info-Banner unten
                VStack(spacing: 4) {
                    if isSearching {
                        ProgressView()
                            .progressViewStyle(.circular)
                            .tint(.white)
                        Text("Suche nach Restaurants...")
                            .font(.caption)
                            .foregroundStyle(.white)
                    } else {
                        Text("📍 \(currentCity)")
                            .font(.headline)
                            .foregroundStyle(.white)
                        Text("\(restaurants.count) Restaurants gefunden")
                            .font(.caption)
                            .foregroundStyle(.white.opacity(0.9))
                    }
                }
                .padding()
                .background {
                    RoundedRectangle(cornerRadius: 12)
                        .fill(.ultraThinMaterial)
                }
                .padding()
            }
        }
        .sheet(isPresented: $showCitySearch) {
            CitySearchSheet(
                searchText: $searchText,
                onSearch: { cityName in
                    showCitySearch = false
                    Task {
                        await performCitySearch(cityName)
                    }
                }
            )
        }
        .alert("Stadt nicht gefunden", isPresented: $showErrorAlert) {
            Button("OK", role: .cancel) { }
        } message: {
            Text(errorMessage)
        }
        .task {
            await loadDefaultCity()
        }
    }
    
    //MARK: - Finding Methods
    
    /// Lädt die Standard-Stadt (Celle) beim Start
    private func loadDefaultCity() async {
        await performCitySearch("Celle")
    }
    
    /// Setzt die Ansicht auf die Standard-Stadt zurück
    private func resetToDefaultCity() {
        searchText = ""
        Task {
            await performCitySearch("Celle")
        }
    }
    
    /// Sucht nach einer Stadt und deren Restaurants
    private func performCitySearch(_ cityName: String) async {
        guard !cityName.isEmpty else { return }
        
        isSearching = true
        
        guard let city = await findCity(named: cityName) else {
            isSearching = false
            errorMessage = "Die Stadt '\(cityName)' konnte nicht gefunden werden. Bitte versuche es mit einem anderen Namen."
            showErrorAlert = true
            return
        }
        
        currentCity = city.name ?? cityName
        restaurants = await findRestaurant(in: city)
        
        // Kamera auf die neue Stadt zentrieren
        withAnimation {
            position = .region(
                MKCoordinateRegion(
                    center: city.placemark.coordinate,
                    span: MKCoordinateSpan(latitudeDelta: 0.05, longitudeDelta: 0.05)
                )
            )
        }
        
        isSearching = false
    }
    
    func findCity(named cityName: String) async -> MKMapItem?  {
        let request = MKLocalSearch.Request()
        request.naturalLanguageQuery = cityName
        
        request.addressFilter = MKAddressFilter(
            including: .locality
        )
        
        let search = MKLocalSearch(request: request)
        let response = try? await search.start()
        
        return response?.mapItems.first
    }
    
    // Alte Methode für Kompatibilität beibehalten
    func findCity() async -> MKMapItem?  {
        return await findCity(named: "celle")
    }
    
    private func findRestaurant(
        in city: MKMapItem
    ) async -> [MKMapItem] {
        let request = MKLocalSearch.Request()
        request.naturalLanguageQuery = "restaurant"
        let downtown = MKCoordinateRegion(
            center: city.location.coordinate,
            span: .init(latitudeDelta: 0.01, longitudeDelta: 0.01
                       )
    )
        request.region = downtown
        request.regionPriority = .required
        let search = MKLocalSearch(request: request)
        let response = try? await search.start()
        
        return response?.mapItems ?? []
    }
}

#Preview {
    MapView()
}
// MARK: - City Search Sheet

struct CitySearchSheet: View {
    @Binding var searchText: String
    @Environment(\.dismiss) private var dismiss
    let onSearch: (String) -> Void
    
    var body: some View {
        NavigationStack {
            VStack(spacing: 20) {
                Text("Stadt suchen")
                    .font(.title2)
                    .bold()
                
                TextField("Stadtname eingeben...", text: $searchText)
                    .textFieldStyle(.roundedBorder)
                    .padding()
                    .submitLabel(.search)
                    .onSubmit {
                        performSearch()
                    }
                
                Button {
                    performSearch()
                } label: {
                    HStack {
                        Image(systemName: "magnifyingglass")
                        Text("Suchen")
                    }
                    .frame(maxWidth: .infinity)
                    .padding()
                    .background(searchText.isEmpty ? Color.gray : Color.blue)
                    .foregroundStyle(.white)
                    .cornerRadius(10)
                }
                .disabled(searchText.isEmpty)
                .padding(.horizontal)
                
                // Vorschläge
                VStack(alignment: .leading, spacing: 12) {
                    Text("Beliebte Städte:")
                        .font(.headline)
                        .padding(.horizontal)
                    
                    ScrollView {
                        VStack(spacing: 8) {
                            ForEach(["Berlin", "Hamburg", "München", "Köln", "Frankfurt", "Stuttgart", "Düsseldorf", "Leipzig", "Hannover", "Bremen"], id: \.self) { city in
                                Button {
                                    searchText = city
                                    performSearch()
                                } label: {
                                    HStack {
                                        Image(systemName: "mappin.circle.fill")
                                        Text(city)
                                        Spacer()
                                        Image(systemName: "arrow.right")
                                    }
                                    .padding()
                                    .background(Color(.systemGray6))
                                    .cornerRadius(8)
                                }
                                .foregroundStyle(.primary)
                            }
                        }
                        .padding(.horizontal)
                    }
                }
                
                Spacer()
            }
            .padding(.top)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Abbrechen") {
                        dismiss()
                    }
                }
            }
        }
        .presentationDetents([.medium, .large])
    }
    
    private func performSearch() {
        guard !searchText.isEmpty else { return }
        onSearch(searchText)
    }
}

