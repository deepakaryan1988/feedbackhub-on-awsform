export interface Feedback {
  _id?: string
  name: string
  message: string
  createdAt: Date
}

export interface FeedbackFormData {
  name: string
  message: string
}

export interface ApiResponse<T> {
  success: boolean
  data?: T
  error?: string
} 