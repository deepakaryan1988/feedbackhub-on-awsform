import { motion } from 'framer-motion'
import { fadeInUp } from '../lib/animations'

export default function HeroSection() {
  return (
    <motion.div 
      className="text-center mb-16"
      initial="hidden"
      animate="visible"
      variants={fadeInUp}
    >
      <motion.h1 
        className="text-5xl md:text-6xl font-bold text-white mb-6 bg-gradient-to-r from-white to-gray-300 bg-clip-text text-transparent"
        variants={fadeInUp}
        transition={{ delay: 0.1 }}
      >
        Welcome to FeedbackHub
      </motion.h1>
      <motion.p 
        className="text-xl md:text-2xl text-gray-300 leading-relaxed max-w-2xl mx-auto"
        variants={fadeInUp}
        transition={{ delay: 0.2 }}
      >
        Collect and view feedback effortlessly
      </motion.p>
      <motion.div 
        className="mt-8 flex justify-center"
        variants={fadeInUp}
        transition={{ delay: 0.3 }}
      >
        <div className="w-16 h-1 bg-gradient-to-r from-blue-500 to-purple-600 rounded-full"></div>
      </motion.div>
    </motion.div>
  )
} 