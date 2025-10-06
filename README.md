# Movies App 🎬

## Overview
An iOS app that displays a list of top‑rated movies from TMDB with pagination, search, favorites, and a details screen. Works offline via Core Data cache and reacts to network changes.

## Key Features ✨
- Top Rated: two‑column grid, parallel pagination (two pages per batch), “load more” footer.
- Search: title search with debounce and offline search on cache.
- Details: poster, title, rating, overview, release date, trailer (YouTube key), full‑screen poster.
- Favorites: add/remove, local persistence, fast UI updates across screens.
- Offline Caching: Core Data cache; offline banner and behavior.
- Network Monitor: connectivity banner and disabled actions when offline.

## Architecture 🏗️
Clean Architecture with clear boundaries:
- Data: networking (URLSession), DTOs, mappers, Core Data, repositories/stores.
- Domain: entities, protocols, use cases — no UI/framework dependencies.
- Presentation: UIKit + SwiftUI (details screen), ViewModel + ViewController/Router/UIFactory.

Dependencies are built in `DIContainer` (App layer).

## Technologies 🛠️
- Swift 6, UIKit + SwiftUI (details), Combine, async/await
- URLSession, SDWebImage (only external dependency)
- Core Data

## UX/Loading
- Lists use the system `UIActivityIndicatorView` for initial and refresh loading.
- Pagination footer shows its own spinner and retry message.

## Error Handling
- Unified `AppError` mapping NSURLError/HTTP/Decoding/DataStore.
- Retry policy for transient/network/429 errors.

## Localization 🌐
- `en`, `uk`, `Base` through `Localizable.strings` + type‑safe keys in `L10n` (e.g., `rating_prefix`).

## Tests 🧪
- Domain use cases covered (including favorites and network status), plus mappers/decoding.
- Mocks live under `MoviesTests/Mocks`.

## Setup & Run 🚀
1) Clone
```bash
git clone <repository_url>
cd Movies
```

2) Open in Xcode
- Open `Movies.xcodeproj`.

3) Configure TMDB via xcconfig
- Copy the example and fill your values:
```bash
cp Movies/App/Config/Config.example.xcconfig Movies/App/Config/Config.xcconfig
```
- Edit `Movies/App/Config/Config.xcconfig`:
  - `TMDB_BASE_URL = https://api.themoviedb.org/3`
  - `TMDB_API_KEY = <your_key>`
  - `TMDB_IMAGE_BASE = https://image.tmdb.org/t/p/`
- Ensure `Info.plist` references these keys; `DIContainer` reads them at runtime.

4) Core Data (verify)
- The project expects `Movies.xcdatamodeld` with `MovieEntity` (attributes used by `MovieEntityMapper`). If missing, add the model in Xcode and include CoreData.framework.

5) Run
- Select a simulator/device and press `Cmd + R`.

## Project Structure 📂
- `Movies/App` — DI, App/SceneDelegate, router, network monitor, config
- `Movies/Data` — API, DTOs, mappers, Core Data, repositories, stores
- `Movies/Domain` — entities, interfaces, use cases, errors
- `Movies/Presentation` — screens, VMs, routers, UIFactory, layouts/collections
- `MoviesTests` — tests, mocks, fixtures

## Assignment Summary
This project implements the requested flows:
- Top Rated (TMDB) with two‑column grid, pull‑to‑refresh, initial center loader, and parallel pagination (2 pages per batch). Average rating across loaded items can be bound to the nav bar from the ViewModel.
- Details screen via SwiftUI (hosted in UIHostingController), with poster, title, rating, overview, release date, add/remove favorites, and full‑screen poster; trailer key support.
- Favorites with local persistence and modal custom transition.
- Search (TMDB) starting from 3 characters with debounce; two‑column grid.
