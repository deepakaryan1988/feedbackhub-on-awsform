import { Feedback } from '../types/feedback'

interface FeedbackListProps {
  feedbacks: Feedback[]
  isLoading?: boolean
}

export default function FeedbackList({ feedbacks, isLoading = false }: FeedbackListProps) {
  if (isLoading) {
    return (
      <div className="space-y-4">
        {[...Array(3)].map((_, i) => (
          <div key={i} className="bg-white p-4 rounded-lg shadow animate-pulse">
            <div className="h-4 bg-gray-200 rounded w-1/4 mb-2"></div>
            <div className="h-4 bg-gray-200 rounded w-full"></div>
          </div>
        ))}
      </div>
    )
  }

  if (feedbacks.length === 0) {
    return (
      <div className="text-center py-8">
        <p className="text-gray-500 text-lg">No feedback submitted yet. Be the first to share your thoughts!</p>
      </div>
    )
  }

  return (
    <div className="space-y-4">
      {feedbacks.map((feedback) => (
        <div key={feedback._id} className="bg-white p-6 rounded-lg shadow-sm border border-gray-200">
          <div className="flex justify-between items-start mb-2">
            <h3 className="font-semibold text-gray-900">{feedback.name}</h3>
            <span className="text-sm text-gray-500">
              {new Date(feedback.createdAt).toLocaleDateString('en-US', {
                year: 'numeric',
                month: 'short',
                day: 'numeric',
                hour: '2-digit',
                minute: '2-digit'
              })}
            </span>
          </div>
          <p className="text-gray-700 leading-relaxed">{feedback.message}</p>
        </div>
      ))}
    </div>
  )
} 