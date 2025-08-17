Create a modern web application that serves as the web version of the BandSpace mobile app - a collaborative music platform for band members
  to share, manage, and collaborate on musical projects.

  🎨 Design System & UI Requirements

  Color Scheme (Dark Theme)

  - Primary Brand Color: #273486 (BandSpace Blue)
  - Primary Light: #3A4DB0
  - Primary Dark: #1A2360
  - Accent: #2563EB (Blue-600)
  - Accent Light: #60A5FA (Blue-400)
  - Background: #111827 (Gray-900)
  - Surface: #1F2937 (Gray-800)
  - Surface Medium: #374151 (Gray-700)
  - Text Primary: #FFFFFF
  - Text Secondary: #D1D5DB (Gray-300)
  - Text Hint: #6B7280 (Gray-500)
  - Border: #374151 (Gray-700)
  - Error: #FF7979 (Red accent)
  - Success: #10B981 (Emerald-500)

  Typography

  - Use modern, clean fonts (Inter, Poppins, or similar)
  - Maintain clear hierarchy with proper font weights
  - Ensure good contrast for accessibility

  Component Design Patterns

  - Cards: Rounded corners (12px), subtle borders, dark surface background
  - Buttons:
    - Primary: Gradient blue background, white text, rounded (16px)
    - Secondary: Outlined with border, secondary text color
    - Text buttons: Minimal style with accent colors
  - Input Fields: Dark surface, rounded (16px), focus states with accent color
  - Icons: Use Lucide icons or similar minimal icon set
  - Shadows: Subtle, dark-themed shadows for depth

  📱 Core Features & User Stories

  1. Authentication System

  - Google OAuth Integration: Primary login method with prominent Google button
  - Email/Password Authentication: Secondary option with clean form design
  - Password Reset: Email-based password recovery
  - User Registration: Simple email/password signup

  2. Dashboard

  - Projects Overview: Grid/list view of user's music projects
  - Project Creation: Modal/form to create new projects
  - Invitations Management: Accept/decline project invitations
  - User Profile: Avatar, name, basic settings in header/drawer

  3. Project Management

  - Project Details: Project name, members, creation date
  - Songs List: All songs within a project with search/filter
  - Member Management: View project members, invite new users
  - Project Settings: Edit project name, delete project (admin only)

  4. Song Management

  - Song Upload: File upload with metadata (title, BPM, lyrics)
  - Audio Player: Full-featured player with progress bar, controls
  - Song Details: Title, creator, creation date, file info
  - Song Operations: Edit metadata, delete songs

  5. Audio Player Features

  - Playback Controls: Play/pause, seek, volume control
  - Progress Display: Current time, total duration, visual progress bar
  - Song Navigation: Previous/next song in project

  🔧 Technical Stack Recommendations

  Frontend Framework

  - React with TypeScript

  State Management

  - Redux Toolkit

  UI Framework

  - Tailwind CSS for styling (matches the mobile app's utility-first approach)
  - Headless UI or Radix UI for accessible components
  - Framer Motion for animations

  Audio Handling

  - Howler.js for robust audio playback
  - Web Audio API for advanced audio features
  - Wavesurfer.js for waveform visualization (optional)

  🌐 API Integration

  Base URL

  https://bandspace-app-b8372bfadc38.herokuapp.com/

  Authentication Endpoints

  // Login with email/password
  POST /api/auth/login
  Body: { email: string, password: string }
  Response: { accessToken: string, refreshToken: string, user: User }

  // Google OAuth login
  POST /api/auth/google/mobile
  Body: { token: string }
  Response: { accessToken: string, refreshToken: string, user: User }

  // Register new user
  POST /api/auth/register
  Body: { email: string, password: string }
  Response: { accessToken: string, user: User }

  // Logout
  POST /api/auth/logout

  // Password reset request
  POST /api/auth/password/request-reset
  Body: { email: string }

  // Password reset
  POST /api/auth/password/reset
  Body: { token: string, newPassword: string }

  // Change password
  PATCH /api/auth/change-password
  Body: { currentPassword: string, newPassword: string }

  Projects Endpoints

  // Get user's projects
  GET /api/projects
  Response: Project[]

  // Create new project
  POST /api/projects
  Body: { name: string, description?: string }
  Response: Project

  // Get project details
  GET /api/projects/{projectId}
  Response: Project

  // Update project
  PATCH /api/projects/{projectId}
  Body: { name: string }
  Response: Project

  // Delete project
  DELETE /api/projects/{projectId}

  // Get project songs
  GET /api/projects/{projectId}/songs
  Response: Song[]

  // Upload new song
  POST /api/projects/{projectId}/songs
  Body: FormData with file and metadata
  Response: Song

  // Update song
  PATCH /api/projects/{projectId}/songs/{songId}
  Body: { title?: string, bpm?: number, lyrics?: string }
  Response: Song

  // Delete song
  DELETE /api/projects/{projectId}/songs/{songId}

  // Get song download URL
  GET /api/projects/{projectId}/songs/{songId}/download
  Response: { url: string, expiresAt: string }

  User & Members Endpoints

  // Get project members
  GET /api/projects/{projectId}/members
  Response: User[]

  // Invite user to project
  POST /api/projects/{projectId}/invitations
  Body: { email: string }

  // Get user invitations
  GET /api/user/invitations
  Response: ProjectInvitation[]

  // Accept/decline invitation
  PATCH /api/user/invitations/{invitationId}
  Body: { action: 'accept' | 'decline' }

  📊 Data Models

  User Model

  interface User {
    id: number;
    email: string;
    name?: string;
  }

  Project Model

  interface Project {
    id: number;
    name: string;
    slug: string;
    createdAt: string;
    updatedAt: string;
    users: User[];
  }

  Song Model

  interface Song {
    id: number;
    title: string;
    createdBy: User;
    createdAt: string;
    updatedAt: string;
    file: {
      id: number;
      fileName: string;
      mimeType: string;
      size: number;
      url: string;
    };
    duration?: number; // in milliseconds
    bpm?: number;
    lyrics?: string;
  }

  Session Model

  interface Session {
    accessToken: string;
    refreshToken: string;
    user: User;
  }

  🎯 Key Implementation Requirements

  1. Responsive Design

  - Desktop-first approach
  - Tablet and mobile optimizations (optional)
  - Keyboard and mouse friendly interfaces

  2. Authentication Flow

  - JWT token management with refresh logic
  - Persistent login state
  - Automatic token renewal

  3. File Upload & Audio Handling

  - Drag-and-drop file upload
  - Progress indicators for uploads
  - Audio format validation (MP3, WAV, etc.)
  - Proper error handling for large files

  4. Real-time Features (Optional Enhancement)

  - WebSocket connections for live collaboration
  - Real-time project updates
  - Live cursor positions during audio playback

  5. Performance Optimization

  - Lazy loading for large song lists
  - Audio preloading strategies
  - Efficient state management
  - Proper caching mechanisms

  🔐 Security Considerations

  - Secure file upload validation
  - XSS protection
  - CSRF protection
  - Proper authentication token handling
  - Input sanitization

  This web application should maintain the same elegant, dark-themed aesthetic as the mobile app while providing a seamless experience across
  all devices. Focus on clean, intuitive interfaces that prioritize usability and visual hierarchy.