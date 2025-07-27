# FeedbackHub 🚀

A modern feedback collection app built with Next.js, MongoDB, and shadcn/ui.

## 🎯 Features

- ✅ Real-time feedback submission
- ✅ MongoDB database integration
- ✅ Modern UI with shadcn/ui components
- ✅ Toast notifications
- ✅ Responsive design
- ✅ Dark mode support

## 🚀 Quick Start

### Option 1: MongoDB Atlas (Recommended)

1. **Setup MongoDB Atlas:**
   ```bash
   ./setup-atlas.sh
   ```

2. **Update credentials in `.env.local`:**
   ```env
   MONGO_URL=mongodb+srv://your-username:your-password@your-cluster.mongodb.net/feedbackhub?retryWrites=true&w=majority
   ```

3. **Start the app:**
   ```bash
   npm run dev:atlas
   ```

4. **Open your browser:**
   ```
   http://localhost:3000
   ```

### Option 2: Docker Compose (Production)

1. **Set environment variables:**
   ```bash
   export MONGO_USERNAME=your-username
   export MONGO_PASSWORD=your-password
   export MONGO_CLUSTER_URL=your-cluster.mongodb.net
   ```

2. **Start with Docker:**
   ```bash
   cd docker
   docker-compose up --build
   ```

3. **Open your browser:**
   ```
   http://localhost:3000
   ```

## 🛠️ Tech Stack

- **Frontend:** Next.js 14, React 18, TypeScript
- **Styling:** Tailwind CSS, shadcn/ui
- **Database:** MongoDB
- **Icons:** Lucide React
- **Animations:** Framer Motion

## 📁 Project Structure

```
feedbackhub-on-awsform/
├── app/                    # Next.js app directory
│   ├── api/               # API routes
│   ├── components/        # React components
│   ├── lib/              # Utilities and database
│   └── types/            # TypeScript types
├── docker/               # Docker configuration
├── lib/                  # Shared utilities
└── components/           # UI components
```

## 🔧 Development

### Prerequisites
- Node.js 20+
- Docker (for MongoDB)
- npm or yarn

### Environment Variables
Create a `.env.local` file:
```env
MONGO_URL=mongodb+srv://your-username:your-password@your-cluster.mongodb.net/feedbackhub?retryWrites=true&w=majority
```

### Available Scripts
- `npm run dev` - Start development server
- `npm run dev:atlas` - Start with MongoDB Atlas
- `npm run build` - Build for production
- `npm run start` - Start production server

## 🐳 Docker Commands

```bash
# Setup MongoDB Atlas
./setup-atlas.sh

# Start full stack with Docker Compose
cd docker && docker-compose up --build

# View logs
cd docker && docker-compose logs -f

# Stop services
cd docker && docker-compose down
```

## 📝 API Endpoints

- `GET /api/feedback` - Get all feedbacks
- `POST /api/feedback` - Submit new feedback

## 🎨 UI Components

Built with shadcn/ui:
- Button, Input, Textarea
- Card, Badge
- Toast notifications
- Loading states

## 🔄 Database Schema

```typescript
interface Feedback {
  _id?: string
  name: string
  message: string
  createdAt: Date
}
```

## 🚀 Deployment

The app is ready for deployment to:
- Vercel
- Netlify
- AWS ECS
- Any Node.js hosting platform

## 📄 License

MIT License