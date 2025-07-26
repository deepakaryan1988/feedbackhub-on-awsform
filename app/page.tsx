'use client'

import { useState, useEffect } from 'react'
import FeedbackForm from '../components/FeedbackForm'
import FeedbackList from '../components/FeedbackList'
import { Feedback, FeedbackFormData } from '../types/feedback'

export default function HomePage() {
  const [feedbacks, setFeedbacks] = useState<Feedback[]>([])
  const [isLoading, setIsLoading] = useState(false)
  const [isSubmitting, setIsSubmitting] = useState(false)

  useEffect(() => {
    fetchFeedbacks()
  }, [])

  const fetchFeedbacks = async () => {
    setIsLoading(true)
    try {
      const response = await fetch('/api/feedback')
      const data = await response.json()
      if (data.success) {
        setFeedbacks(data.data || [])
      }
    } catch (error) {
      console.error('Error fetching feedbacks:', error)
    } finally {
      setIsLoading(false)
    }
  }

  const handleSubmitFeedback = async (formData: FeedbackFormData) => {
    setIsSubmitting(true)
    try {
      const response = await fetch('/api/feedback', {
        method: 'POST',
        headers: {
          'Content-Type': 'application/json',
        },
        body: JSON.stringify(formData),
      })

      const data = await response.json()
      if (data.success) {
        // Refresh the feedback list
        await fetchFeedbacks()
      } else {
        console.error('Error submitting feedback:', data.error)
      }
    } catch (error) {
      console.error('Error submitting feedback:', error)
    } finally {
      setIsSubmitting(false)
    }
  }

  return (
    <div className="container mx-auto px-4 py-8 max-w-4xl">
      <div className="text-center mb-12">
        <h1 className="text-4xl font-bold text-gray-900 mb-4">
          FeedbackHub
        </h1>
        <p className="text-xl text-gray-600">
          Share your thoughts and help us improve
        </p>
      </div>

      <div className="grid grid-cols-1 lg:grid-cols-2 gap-8">
        {/* Feedback Form Section */}
        <div className="bg-white p-6 rounded-lg shadow-sm border border-gray-200">
          <h2 className="text-2xl font-semibold text-gray-900 mb-6">
            Submit Feedback
          </h2>
          <FeedbackForm onSubmit={handleSubmitFeedback} isLoading={isSubmitting} />
        </div>

        {/* Feedback List Section */}
        <div className="bg-white p-6 rounded-lg shadow-sm border border-gray-200">
          <h2 className="text-2xl font-semibold text-gray-900 mb-6">
            Recent Feedback
          </h2>
          <FeedbackList feedbacks={feedbacks} isLoading={isLoading} />
        </div>
      </div>

      {/* Footer */}
      <div className="mt-12 text-center text-gray-500">
        <p>FeedbackHub - AWS ECS Fargate Deployment</p>
        <p className="text-sm mt-2">Built with Next.js 14 and MongoDB</p>
      </div>
    </div>
  )
} 