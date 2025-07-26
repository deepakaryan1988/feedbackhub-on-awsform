import { motion } from 'framer-motion'
import { Feedback } from '../types/feedback'
import { staggerContainer, cardEntrance } from '../lib/animations'

interface FeedbackListProps {
  feedbacks: Feedback[]
  isLoading?: boolean
}

export default function FeedbackList({ feedbacks, isLoading = false }: FeedbackListProps) {
  if (isLoading) {
    return (
      <motion.div 
        className="space-y-4"
        initial="hidden"
        animate="visible"
        variants={staggerContainer}
      >
        {[...Array(3)].map((_, i) => (
          <motion.div 
            key={i} 
            className="bg-neutral-700/30 p-6 rounded-xl border border-neutral-600/50 animate-pulse backdrop-blur-sm"
            variants={cardEntrance}
          >
            <div className="h-4 bg-neutral-600 rounded w-1/4 mb-3"></div>
            <div className="h-4 bg-neutral-600 rounded w-full mb-2"></div>
            <div className="h-3 bg-neutral-600 rounded w-3/4"></div>
          </motion.div>
        ))}
      </motion.div>
    )
  }

  if (feedbacks.length === 0) {
    return (
      <motion.div 
        className="text-center py-12"
        initial={{ opacity: 0, y: 20 }}
        animate={{ opacity: 1, y: 0 }}
        transition={{ duration: 0.5, ease: [0.25, 0.46, 0.45, 0.94] }}
      >
        <div className="w-16 h-16 mx-auto mb-4 rounded-full bg-neutral-700/50 flex items-center justify-center">
          <svg className="w-8 h-8 text-neutral-400" fill="none" stroke="currentColor" viewBox="0 0 24 24">
            <path strokeLinecap="round" strokeLinejoin="round" strokeWidth={2} d="M8 12h.01M12 12h.01M16 12h.01M21 12c0 4.418-4.03 8-9 8a9.863 9.863 0 01-4.255-.949L3 20l1.395-3.72C3.512 15.042 3 13.574 3 12c0-4.418 4.03-8 9-8s9 3.582 9 8z" />
          </svg>
        </div>
        <p className="text-neutral-300 text-lg font-medium">No feedback yet</p>
        <p className="text-neutral-500 text-sm mt-2">Be the first to share your thoughts!</p>
      </motion.div>
    )
  }

  return (
    <motion.div 
      className="space-y-4"
      initial="hidden"
      animate="visible"
      variants={staggerContainer}
    >
      {feedbacks.map((feedback, index) => (
        <motion.div 
          key={feedback._id} 
          className="bg-neutral-700/30 p-6 rounded-xl border border-neutral-600/50 hover:border-neutral-500/50 hover:bg-neutral-700/40 transition-all duration-200 backdrop-blur-sm group"
          variants={cardEntrance}
          custom={index}
        >
          <div className="flex justify-between items-start mb-3">
            <h3 className="font-semibold text-white group-hover:text-blue-300 transition-colors">
              {feedback.name}
            </h3>
            <span className="text-sm text-neutral-400 bg-neutral-800/50 px-2 py-1 rounded-md">
              {new Date(feedback.createdAt).toLocaleDateString('en-US', {
                year: 'numeric',
                month: 'short',
                day: 'numeric',
                hour: '2-digit',
                minute: '2-digit'
              })}
            </span>
          </div>
          <p className="text-neutral-300 leading-relaxed">{feedback.message}</p>
        </motion.div>
      ))}
    </motion.div>
  )
} 