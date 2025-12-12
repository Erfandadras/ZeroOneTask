# Hospital Finder - iOS App

A SwiftUI-based iOS application for finding nearby hospitals with real-time travel directions and comprehensive hospital information.

**Test Project for ZeroOneTech**

---

## 📋 Table of Contents

- [Architecture](#architecture)
- [Setup Instructions](#setup-instructions)
- [Mock Data](#mock-data)
- [Design System](#design-system)
- [API Recommendations](#api-recommendations)
- [Configuration](#configuration)
- [Features](#features)

---

## 🏗 Architecture

The app follows **MVVM** with **Protocol-Oriented Programming (POP)** and **Dependency Injection** for a clean, testable, and maintainable codebase.

### Key Components:

```
┌─────────────────────────────────────────────────────────────┐
│                         MapScreenView                        │
│                        (SwiftUI View)                        │
└─────────────────────────────────┬───────────────────────────┘
                                  │
                     ┌────────────┴────────────┐
                     │                         │
            ┌────────▼────────┐     ┌─────────▼──────────┐
            │  MapScreenVM    │     │ HospitalDetailView │
            │  (ViewModel)    │     │   (SwiftUI View)   │
            └────────┬────────┘     └────────────────────┘
                     │
        ┌────────────┼────────────┐
        │            │            │
┌───────▼───────┐ ┌──▼──────────┐ ┌──▼──────────────┐
│ HospitalSearch│ │ Directions  │ │     Models      │
│   Service     │ │   Service   │ │  Hospital       │
│  (Protocol)   │ │  (Protocol) │ │  HospitalUIItem │
└───────────────┘ └─────────────┘ └─────────────────┘
```

### Layers:

- **View Layer**: SwiftUI views (MapScreenView, HospitalDetailView)
- **ViewModel Layer**: Observable ViewModels with business logic
- **Service Layer**: Protocol-based services for data fetching
- **Model Layer**: Data models (Hospital) and UI models (HospitalUIItem)

### Benefits:

✅ **Dependency Injection** - Easy testing with mock services  
✅ **Protocol-Oriented** - Flexible and extensible  
✅ **Separation of Concerns** - Clear responsibilities  
✅ **Reactive** - SwiftUI's `@Observable` for state management  

---

## 🚀 Setup Instructions

### Prerequisites:

- Xcode 15.0+
- iOS 17.0+
- Swift 5.9+

### Installation:

1. **Clone the repository**
   ```bash
   git clone <repository-url>
   cd ZeroOneErfanTest
   ```

2. **Open the project**
   ```bash
   open ZeroOneErfanTask.xcodeproj
   ```

3. **Add URL Schemes to Info.plist** (for Google Maps & Waze integration)
   
   Add the following to your `Info.plist`:
   ```xml
   <key>LSApplicationQueriesSchemes</key>
   <array>
       <string>comgooglemaps</string>
       <string>waze</string>
   </array>
   ```

4. **Build and Run**
   - Select your target device/simulator
   - Press `Cmd + R` to build and run

---

## 🎭 Mock Data

### Current Implementation:

The app uses **mock data** for demonstration purposes:

#### Hospital Search Service:
- Uses Apple's `MKLocalSearch` API to find real hospital locations
- Generates mock data for:
  - Availability status (80% available)
  - Waiting times (5-120 minutes)
  - Ratings (1.0-5.0)
  - Last update timestamps

#### Travel Directions:
- Uses Apple's `MKDirections` API for real route calculations
- Calculates actual travel times for:
  - 🚗 Car (driving mode)
  - 🚌 Public transportation (transit mode)
  - 🚶 Walking (for distances < 10km)

#### Static Mock Data:
For testing and previews, static mock data is available:
```swift
HospitalUIItem.mockItem  // Single hospital
```

---

## 🎨 Design System

### ⚠️ Important Note on Colors and Fonts:

**I did not have access to the actual design system colors and fonts for this project.**

### Current Implementation:

The app uses custom color and font extensions that can be easily replaced:

#### Colors:
```swift
// Current: Custom colors defined in ColorStyle.swift
.foregroundStyle(.ui.textPrimary)
.background(.ui.blue)
```

**To update**: Modify `Core/Base/ColorStyle.swift` with your actual brand colors.

#### Fonts:
```swift
// Current: Poppins font family
.font(.ui.mRegular)
.font(Font.Poppins.semiBold(16))
```

**To update**: 
1. Add your font files to `Core/Resources/Fonts/`
2. Update `Core/Resources/Fonts/Font.swift`
3. Replace font references throughout the app

### Easy Migration:

All colors and fonts use semantic naming (`.ui.textPrimary`, `.ui.blue`, etc.), making it simple to update the entire app by modifying the base style files.

---

## 🌐 API Recommendations

### Current vs. Production:

| Feature | Current (Test) | Production Recommendation |
|---------|---------------|--------------------------|
| **Hospital Data** | `MKLocalSearch` + Mock | ✅ Use dedicated Hospital API |
| **Travel Times** | `MKDirections` | ✅ Keep (accurate & native) |
| **Availability** | Random mock | ✅ Real-time API endpoint |
| **Waiting Times** | Random mock | ✅ Real-time API endpoint |
| **Ratings** | Random mock | ✅ Hospital rating service |

### Recommended Production API:

```swift
protocol HospitalAPIServiceProtocol {
    func fetchHospitals(
        location: CLLocationCoordinate2D,
        radius: Double
    ) async throws -> [HospitalResponse]
    
    func fetchHospitalDetails(
        hospitalId: String
    ) async throws -> HospitalDetails
    
    func fetchRealTimeAvailability(
        hospitalId: String
    ) async throws -> AvailabilityInfo
}
```

### Benefits of Using Real API:

✅ **Real-time availability** - Actual bed/resource availability  
✅ **Accurate waiting times** - Live emergency room wait times  
✅ **Verified ratings** - Actual patient reviews  
✅ **Complete data** - Services, departments, specialties  
✅ **Historical data** - Trends and patterns  

---

## ⚙️ Configuration

### Location Settings:

#### Center Location:

**Current (Test Mode):**
```swift
// Fixed center for testing
let centerCoordinate = CLLocationCoordinate2D(
    latitude: 43.82,   // Toronto, Canada
    longitude: -79.34
)
```

**Production Recommendation:**
```swift
// Use actual user location
@StateObject private var locationManager = LocationManager()

var centerCoordinate: CLLocationCoordinate2D {
    locationManager.location ?? defaultLocation
}
```

**Options for Production:**
1. **User's Current Location** (Recommended)
   - Request location permission
   - Use `LocationManager` to get GPS coordinates
   - Update center as user moves

2. **Manual Entry**
   - Allow user to search and set location
   - Save preferred locations
   - Switch between multiple locations

3. **Hybrid Approach**
   - Default to user location
   - Allow manual override
   - Remember last used location

### Search Radius:

**Current:**
```swift
let searchRadius: CLLocationDistance = 20000 // 20km fixed
```

**To Implement User Selection:**
1. Add radius picker to UI
2. Store preference in `UserDefaults`
3. Update `searchRadius` variable
4. Rerun search with new radius

---

## ✨ Features

### Core Features:

- 🗺 **Interactive Map** - View hospitals on Apple Maps
- 📍 **Location-Based Search** - Find hospitals within radius
- 🔍 **Search & Filter** - Search by name, filter by type
- 📊 **Sorting Options**:
  - Nearest (by distance)
  - Earliest (by waiting time)
- 🚗 **Real-Time Directions** - Calculate actual travel times
- 📱 **Multi-App Navigation** - Open in Apple Maps, Google Maps, or Waze
- ℹ️ **Detailed Information** - View hospital details, ratings, availability
- ⚡️ **Smart Caching** - Fast loading for repeated views
- 🎯 **Hospital Markers** - Custom markers with selection states

### Technical Features:

- **Protocol-Oriented Design** - Clean architecture
- **Dependency Injection** - Testable components
- **Async/Await** - Modern concurrency
- **SwiftUI** - Declarative UI
- **MapKit Integration** - Native map features
- **State Management** - Observable ViewModels
- **Progressive Loading** - Show UI, fetch data in background

---

## 📝 Notes for Production

### 1. Location Permissions:

Add to `Info.plist`:
```xml
<key>NSLocationWhenInUseUsageDescription</key>
<string>We need your location to find nearby hospitals</string>
```

### 2. Network Permissions:

Ensure App Transport Security is properly configured for your API endpoints.

### 3. Error Handling:

Implement comprehensive error handling for:
- Network failures
- API errors
- Location permission denied
- No hospitals found

### 4. Performance:

- Limit initial search results (currently limited to avoid API rate limits)
- Implement pagination for large result sets
- Add debouncing for search queries

### 5. Accessibility:

- Add VoiceOver labels
- Ensure color contrast meets WCAG standards
- Support Dynamic Type

---

## 🧪 Testing

### Mock Services Available:

```swift
// For testing/previews
let mockSearchService = MockHospitalSearchService()
let mockDirectionsService = MockDirectionsService()

// Initialize ViewModel with mocks
let viewModel = MapScreenVM(
    searchService: mockSearchService,
    directionsService: mockDirectionsService
)
```

### Unit Testing:

The protocol-based architecture makes unit testing straightforward:

```swift
func testHospitalSearch() async throws {
    let mockService = MockHospitalSearchService()
    mockService.mockHospitals = [/* test data */]
    
    let viewModel = MapScreenVM(searchService: mockService)
    await viewModel.searchHospitals(near: testCoordinate, radius: 5000)
    
    XCTAssertEqual(viewModel.hospitals.count, expectedCount)
}
```

---

## 📄 License

This project was created as a test assignment for ZeroOneTech.

---

## 👨‍💻 Author

**Erfan Dadras**  
Test Project for ZeroOneTech  
December 2025

---

**Note:** This is a demonstration project. For production use, implement real APIs, proper error handling, analytics, and comprehensive testing.

