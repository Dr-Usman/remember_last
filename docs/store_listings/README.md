# RememberLast — Google Play Store Listings

This folder contains localized store listings ready to copy-paste directly into **Google Play Console** (`Grow > Store presence > Main store listing > Manage languages`).

## Overview of Translations

| Language | Locale Code | File Link | Title (≤ 30) | Short Desc (≤ 80) | Full Desc (≤ 4000) |
| :--- | :--- | :--- | :--- | :--- | :--- |
| **English (Default)** | `en-US` | [store_listing_english.md](file:///Users/usman/Development/Projects/Others/remember_last/docs/store_listings/store_listing_english.md) | 30 chars | 79 chars | 2,703 chars |
| **German (Deutsch)** | `de-DE` | [store_listing_german.md](file:///Users/usman/Development/Projects/Others/remember_last/docs/store_listings/store_listing_german.md) | 30 chars | 75 chars | 2,776 chars |
| **Spanish (Español)** | `es-419` / `es-ES` | [store_listing_spanish.md](file:///Users/usman/Development/Projects/Others/remember_last/docs/store_listings/store_listing_spanish.md) | 26 chars | 73 chars | 2,684 chars |
| **Hindi (हिन्दी)** | `hi-IN` | [store_listing_hindi.md](file:///Users/usman/Development/Projects/Others/remember_last/docs/store_listings/store_listing_hindi.md) | 24 chars | 72 chars | 2,641 chars |
| **Romanian (Română)** | `ro` | [store_listing_romanian.md](file:///Users/usman/Development/Projects/Others/remember_last/docs/store_listings/store_listing_romanian.md) | 26 chars | 76 chars | 2,748 chars |
| **Thai (ภาษาไทย)** | `th` | [store_listing_thai.md](file:///Users/usman/Development/Projects/Others/remember_last/docs/store_listings/store_listing_thai.md) | 29 chars | 61 chars | 2,425 chars |
| **Lithuanian (Lietuvių)** | `lt` | [store_listing_lithuanian.md](file:///Users/usman/Development/Projects/Others/remember_last/docs/store_listings/store_listing_lithuanian.md) | 29 chars | 77 chars | 2,750 chars |
| **Dutch (Nederlands)** | `nl-NL` | [store_listing_dutch.md](file:///Users/usman/Development/Projects/Others/remember_last/docs/store_listings/store_listing_dutch.md) | 27 chars | 76 chars | 2,680 chars |
| **French (Français)** | `fr-FR` | [store_listing_french.md](file:///Users/usman/Development/Projects/Others/remember_last/docs/store_listings/store_listing_french.md) | 27 chars | 74 chars | 2,720 chars |
| **Japanese (日本語)** | `ja-JP` | [store_listing_japanese.md](file:///Users/usman/Development/Projects/Others/remember_last/docs/store_listings/store_listing_japanese.md) | 23 chars | 43 chars | 1,448 chars |

---

## Instructions for Google Play Console

1. Go to **Google Play Console** ➔ **RememberLast**.
2. Navigate to **Grow** ➔ **Store presence** ➔ **Main store listing**.
3. In the language dropdown at the top, click **Manage languages**.
4. Select the languages you want to enable (German, Spanish, Lithuanian, Dutch, French, Hindi, Romanian, Thai, Japanese) and click **Save**.
5. Switch to each language from the dropdown:
   - Copy the **App name**, **Short description**, and **Full description** from the corresponding file above.
   - In the **Phone screenshots** section, upload the 4 corresponding localized mockups from `store_assets/play_store/<country_name>/`.
6. Click **Save** at the bottom right.

---

## Localized Mockup Screenshots (1024x1536)

Pre-rendered high-resolution mockups with localized headlines, 4x supersampled typography, and authentic device frames are saved in clear country-named folders under `store_assets/play_store/`:

- 🇺🇸 **English**: `store_assets/play_store/english/`
- 🇩🇪 **Germany**: `store_assets/play_store/germany/`
- 🇳🇱 **Netherlands & Belgium (Dutch)**: `store_assets/play_store/netherlands/`
- 🇫🇷 **France & Belgium (French)**: `store_assets/play_store/france/`
- 🇯🇵 **Japan**: `store_assets/play_store/japan/`
- 🇪🇸 **Spain & Mexico**: `store_assets/play_store/spain/`
- 🇱🇹 **Lithuania**: `store_assets/play_store/lithuania/`
- 🇮🇳 **India**: `store_assets/play_store/india/`
- 🇷🇴 **Romania**: `store_assets/play_store/romania/`
- 🇹🇭 **Thailand**: `store_assets/play_store/thailand/`

To re-generate all country mockups at any time, run:
```bash
python3 tool/generate_mockups.py
```

