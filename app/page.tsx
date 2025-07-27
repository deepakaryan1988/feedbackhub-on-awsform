'use client'

import { useState, useEffect } from 'react'
import { motion } from 'framer-motion'
import FeedbackForm from './components/FeedbackForm'
import FeedbackList from './components/FeedbackList'
import HeroSection from './components/HeroSection'
import BackgroundPattern from './components/BackgroundPattern'
import { Feedback, FeedbackFormData } from './types/feedback'
import { pageFadeIn, fadeInUp, staggerContainer } from './lib/animations'

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
        // Add the new feedback to the list immediately with animation
        const newFeedback: Feedback = {
          _id: data.data._id,
          name: formData.name,
          message: formData.message,
          createdAt: new Date()
        }
        setFeedbacks(prev => [newFeedback, ...prev])
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
    <div className="min-h-screen bg-gradient-to-tr from-neutral-900 via-neutral-900 to-black relative overflow-hidden">
      {/* Background Pattern */}
      <BackgroundPattern />
      
      {/* Main Content */}
      <motion.div 
        className="relative z-10 max-w-6xl mx-auto px-4 py-20"
        initial="hidden"
        animate="visible"
        variants={pageFadeIn}
      >
        {/* Hero Section */}
        <HeroSection />

        {/* Main Content Grid */}
        <motion.div 
          className="grid grid-cols-1 lg:grid-cols-2 gap-8"
          variants={staggerContainer}
        >
          {/* Feedback Form Section */}
          <motion.div 
            className="bg-neutral-800/50 backdrop-blur-sm p-8 rounded-2xl border border-neutral-700/50 shadow-2xl"
            variants={fadeInUp}
            transition={{ delay: 0.1 }}
          >
            <h2 className="text-2xl font-semibold text-white mb-6">
              Submit Feedback
            </h2>
            <FeedbackForm onSubmit={handleSubmitFeedback} isLoading={isSubmitting} />
          </motion.div>

          {/* Feedback List Section */}
          <motion.div 
            className="bg-neutral-800/50 backdrop-blur-sm p-8 rounded-2xl border border-neutral-700/50 shadow-2xl"
            variants={fadeInUp}
            transition={{ delay: 0.2 }}
          >
            <h2 className="text-2xl font-semibold text-white mb-6">
              Recent Feedback
            </h2>
            <FeedbackList feedbacks={feedbacks} isLoading={isLoading} />
          </motion.div>
        </motion.div>

        {/* Footer */}
        <motion.div 
          className="mt-16 text-center text-neutral-400"
          variants={fadeInUp}
          transition={{ delay: 0.3 }}
        >
          <p className="text-lg">FeedbackHub - AWS ECS Fargate Deployment</p>
          <p className="text-sm mt-2 text-neutral-500">Built with Next.js 14 and MongoDB</p>
        </motion.div>
      </motion.div>
    </div>
  )
} 