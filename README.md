# SkyCast 🌤️

A clean, production-ready Flutter weather app built on the [WeatherAI API](https://weather-ai.co).

## Features

- 📍 **Auto location detection** — GPS with IP geo-fallback via `/v1/weather-geo`
- 🌡️ **Current conditions** — temperature, feels-like, humidity, wind, UV index
- ⏱️ **Hourly forecast** — next 24 hours scrollable strip
- 📅 **7-day forecast** — daily high/low with precipitation probability
- ✨ **AI Summary** — Gemini-powered natural language weather insights
- 🔍 **City search** — geocoded search with recent history
- 🌡️ **Unit toggle** — °C / °F switching
- 🔄 **Pull to refresh**

## Architecture

```
lib/
├── core/
│   ├── constants/      # API & app constants
│   ├── errors/         # Exception types + Result<T> sealed class
│   ├── network/        # Dio API client with interceptors
│   └── utils/          # Location & weather helper utils
├── data/
│   ├── datasources/    # WeatherRemoteDataSource (API calls)
│   ├── models/         # JSON parsing models
│   └── repositories/   # Repository implementations
└── presentation/
    ├── pages/          # HomePage
    ├── providers/      # Riverpod state (WeatherNotifier + WeatherState)
    ├── theme/          # AppTheme
    └── widgets/        # Composable UI components
```

**State management**: [Riverpod](https://riverpod.dev) (`StateNotifier` + `StateNotifierProvider`)  
**HTTP**: [Dio](https://pub.dev/packages/dio) with auth interceptor  
**Error handling**: Sealed `Result<T>` type (no raw exceptions in UI)

## Getting Started

### 1. Clone
```bash
git clone https://github.com/YOUR_USERNAME/skycast.git
cd skycast
```

### 2. Add your API key
```bash
cp .env.example .env
# Edit .env and paste your WeatherAI key
```

`.env`:
```
WEATHER_AI_KEY=wai_your_key_here
```

> Get a free key at [weather-ai.co](https://weather-ai.co) → Dashboard → API Keys

### 3. Install & run
```bash
flutter pub get
flutter run
```

### 4. Build APK
```bash
flutter build apk --release
# Output: build/app/outputs/flutter-apk/app-release.apk
```

## API Endpoints Used

| Endpoint | Purpose |
|---|---|
| `GET /v1/weather` | Current + 7-day forecast by coordinates |
| `GET /v1/weather-geo?ip=auto` | Auto-detect location + weather |

Both return AI-generated Gemini summaries by default.

## Requirements

- Flutter 3.10+
- Dart 3.0+
- WeatherAI free plan (1,000 req/mo)
- Android 5.0+ / iOS 12+

## License

MIT
