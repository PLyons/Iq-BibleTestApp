# Random Bible Verse iOS App

## Overview

This SwiftUI iOS application displays a **random verse from the Holy Bible** each time it is launched or when the user taps the "Get Another Verse" button. It is designed for simplicity and fast inspiration, making it easy for users to encounter Scripture with a single tap.

## Data Source

All Bible data for this app is retrieved in real time from the [IQ Bible API](https://rapidapi.com/websitie-websitie-default/api/iq-bible/) via RapidAPI.  
- The app accesses the **King James Version (KJV)** of the Bible, but the API supports multiple versions and languages.
- The IQ Bible API provides a rich set of features, including access to original Hebrew/Greek texts, Strong’s Concordance, audio, and more.
- Each verse is fetched as a random verse from the entire Bible using a secure API call.
- The app also fetches the book name (e.g., "Genesis") by querying the API with the book’s numeric ID.

**API Home Base:**  
[IQ Bible API on RapidAPI](https://rapidapi.com/websitie-websitie-default/api/iq-bible/)

## How It Works

- On app launch or when the button is tapped, the app sends a request to the IQ Bible API for a random verse.
- The response includes the book number, chapter, verse, and verse text.
- The app then sends a second API request to retrieve the full book name corresponding to the book ID.
- The verse and reference are displayed on screen. The user can tap the button to fetch a new random verse.

## Authentication

- The app uses a personal API key associated with a RapidAPI account.
- **Login Method:** The API key used in this app was obtained by logging into [RapidAPI](https://rapidapi.com/) using a Google account.

## Notes

- This app is for educational and inspirational use.
- Never publish your API key in public repositories.
- The IQ Bible API provides much more than random verses. Explore the API for additional features!

## Credits

- **Data Source:** [IQ Bible API on RapidAPI](https://rapidapi.com/websitie-websitie-default/api/iq-bible/)
- **App Author:** Paul Lyons, with code scaffolding and documentation by ChatGPT-4.1

---



