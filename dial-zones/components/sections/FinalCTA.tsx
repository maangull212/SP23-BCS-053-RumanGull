// components/sections/FinalCTA.tsx
'use client'

import { motion } from 'framer-motion'
import { Button } from '@/components/ui/button'
import { ShieldCheck, Zap, HeadphonesIcon } from 'lucide-react'

export function FinalCTA() {
  return (
    <section className="relative w-full bg-[#0D1B3E] py-24 overflow-hidden">
      {/* Animated Background Elements */}
      <div className="absolute inset-0 z-0 opacity-40">
        <div className="absolute top-0 left-0 w-[500px] h-[500px] bg-[#1A6FF5] rounded-full blur-[150px] mix-blend-screen opacity-50 animate-pulse"></div>
        <div className="absolute bottom-0 right-0 w-[400px] h-[400px] bg-[#06B6D4] rounded-full blur-[150px] mix-blend-screen opacity-30"></div>
      </div>

      <div className="container mx-auto px-4 max-w-4xl relative z-10 text-center">
        <motion.div
          initial={{ opacity: 0, y: 20 }}
          whileInView={{ opacity: 1, y: 0 }}
          viewport={{ once: true }}
          transition={{ duration: 0.6 }}
        >
          <h2 className="text-4xl md:text-5xl font-heading font-bold text-white mb-6">
            Start your free 14-day trial today
          </h2>
          <p className="text-lg md:text-xl text-blue-200 mb-10 max-w-2xl mx-auto">
            No credit card required. Setup takes 5 minutes. Cancel anytime.
          </p>

          {/* Inline Email Form */}
          <form className="flex flex-col sm:flex-row items-center justify-center gap-3 max-w-lg mx-auto mb-10" onSubmit={(e) => e.preventDefault()}>
            <input 
              type="email" 
              placeholder="Enter your work email" 
              required
              className="w-full sm:w-auto flex-1 px-6 py-4 rounded-xl text-white outline-none focus:ring-2 focus:ring-[#1A6FF5] transition-all"
            />
            <Button size="lg" className="w-full sm:w-auto bg-[#1A6FF5] hover:bg-blue-600 text-white rounded-xl px-8 py-7 text-lg font-bold shadow-lg shadow-blue-500/30 transition-transform hover:scale-105">
              Get Started Free
            </Button>
          </form>

          {/* Trust Row */}
          <div className="flex flex-wrap items-center justify-center gap-6 md:gap-12 text-sm text-blue-200/80 font-medium">
            <span className="flex items-center gap-2">
              <ShieldCheck className="w-5 h-5 text-[#1A6FF5]" /> 99.99% Uptime
            </span>
            <span className="flex items-center gap-2">
              <Zap className="w-5 h-5 text-[#1A6FF5]" /> Free Migration
            </span>
            <span className="flex items-center gap-2">
              <HeadphonesIcon className="w-5 h-5 text-[#1A6FF5]" /> 24/7 Support
            </span>
          </div>
        </motion.div>
      </div>
    </section>
  )
}