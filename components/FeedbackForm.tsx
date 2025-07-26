'use client'

import { useState } from 'react'
import { motion } from 'framer-motion'
import { FeedbackFormData } from '../types/feedback'
import { formField, buttonTap } from '../lib/animations'
import LoadingSpinner from './LoadingSpinner'

interface FeedbackFormProps {
  onSubmit: (data: FeedbackFormData) => Promise<void>
  isLoading?: boolean
}

export default function FeedbackForm({ onSubmit, isLoading = false }: FeedbackFormProps) {
  const [formData, setFormData] = useState<FeedbackFormData>({
    name: '',
    message: ''
  })

  const handleSubmit = async (e: React.FormEvent) => {
    e.preventDefault()
    if (!formData.name.trim() || !formData.message.trim()) {
      return
    }
    
    await onSubmit(formData)
    setFormData({ name: '', message: '' })
  }

  const handleChange = (e: React.ChangeEvent<HTMLInputElement | HTMLTextAreaElement>) => {
    const { name, value } = e.target
    setFormData(prev => ({ ...prev, [name]: value }))
  }

  return (
    <motion.form 
      onSubmit={handleSubmit} 
      className="space-y-6"
      initial="hidden"
      animate="visible"
      variants={formField}
    >
      <motion.div variants={formField}>
        <label htmlFor="name" className="block text-sm font-medium text-neutral-200 mb-2">
          Name *
        </label>
        <input
          type="text"
          id="name"
          name="name"
          value={formData.name}
          onChange={handleChange}
          required
          className="w-full px-4 py-3 bg-neutral-700/50 border border-neutral-600 rounded-lg shadow-sm focus:outline-none focus:ring-2 focus:ring-blue-500 focus:border-blue-500 text-white placeholder-neutral-400 transition-all backdrop-blur-sm"
          placeholder="Enter your name"
          disabled={isLoading}
        />
      </motion.div>
      
      <motion.div variants={formField}>
        <label htmlFor="message" className="block text-sm font-medium text-neutral-200 mb-2">
          Message *
        </label>
        <textarea
          id="message"
          name="message"
          value={formData.message}
          onChange={handleChange}
          required
          rows={4}
          className="w-full px-4 py-3 bg-neutral-700/50 border border-neutral-600 rounded-lg shadow-sm focus:outline-none focus:ring-2 focus:ring-blue-500 focus:border-blue-500 text-white placeholder-neutral-400 transition-all backdrop-blur-sm resize-none"
          placeholder="Enter your feedback message"
          disabled={isLoading}
        />
      </motion.div>
      
      <motion.button
        type="submit"
        disabled={isLoading || !formData.name.trim() || !formData.message.trim()}
        className="w-full bg-gradient-to-r from-blue-600 to-purple-600 text-white py-3 px-6 rounded-lg hover:from-blue-700 hover:to-purple-700 focus:outline-none focus:ring-2 focus:ring-blue-500 focus:ring-offset-2 focus:ring-offset-neutral-800 disabled:opacity-50 disabled:cursor-not-allowed transition-all duration-200 flex items-center justify-center space-x-2 shadow-lg"
        variants={buttonTap}
        whileHover="hover"
        whileTap="tap"
      >
        {isLoading ? (
          <>
            <LoadingSpinner size="sm" className="border-white border-t-white" />
            <span>Submitting...</span>
          </>
        ) : (
          'Submit Feedback'
        )}
      </motion.button>
    </motion.form>
  )
} 