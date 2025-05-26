# Namibia Hockey Union Mobile App

A mobile application for the Namibia Hockey Union built with Expo React Native and Supabase.

## Features

- Team registration and management
- Player registration and management
- Event entries and management
- Information sharing (announcements)

## Technologies Used

- Expo React Native
- Supabase for backend functionality
- React Navigation for app navigation
- React Native Elements for UI components

## Setup Instructions

### Prerequisites

- Node.js (v14 or higher)
- npm or yarn
- Expo CLI
- Supabase account

### Installation

1. Clone the repository
2. Install dependencies:
   ```
   npm install
   ```
3. Start the development server:
   ```
   npm start
   ```
   or
   ```
   expo start
   ```

### Supabase Setup

1. Create a new Supabase project
2. Set up the database tables as defined in `src/utils/supabaseSchema.js`
3. Update the Supabase URL and anon key in `src/config/supabase.js` if needed

## Database Schema

The app uses the following tables in Supabase:

- **teams**: Stores hockey team information
- **players**: Stores player information with team associations
- **events**: Stores event information
- **event_registrations**: Tracks team registrations for events
- **announcements**: Stores announcements for information sharing

## App Structure

- **src/screens**: Contains all the screen components
- **src/navigation**: Contains the navigation configuration
- **src/components**: Contains reusable UI components
- **src/config**: Contains configuration files
- **src/utils**: Contains utility functions
- **src/hooks**: Contains custom React hooks

## Usage

- **Teams**: Register and manage hockey teams
- **Players**: Register and manage players with team assignments
- **Events**: Create and manage hockey events
- **Announcements**: Share information with users

## License

This project is licensed under the MIT License.
