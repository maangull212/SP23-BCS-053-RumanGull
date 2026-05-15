// components/sections/HowItWorks.tsx
'use client'

import { motion } from 'framer-motion'
import { UploadCloud, PlayCircle, TrendingUp } from 'lucide-react'
import { Button } from '@/components/ui/button'

const steps = [
  {
    num: "01",
    title: "Import Your Leads",
    description: "Upload your CSV files instantly or sync directly with your existing CRM.",
    icon: UploadCloud,
  },
  {
    num: "02",
    title: "Launch Campaign",
    description: "Configure your dialing rules, assign agents, and hit start. We handle the rest.",
    icon: PlayCircle,
  },
  {
    num: "03",
    title: "Watch Conversions Grow",
    description: "Monitor live call metrics and agent performance from your real-time dashboard.",
    icon: TrendingUp,
  }
]

export function HowItWorks() {
  return (
    <section className="py-24 bg-[#E8F0FD] relative overflow-hidden">
      <div className="container mx-auto px-4 max-w-7xl relative z-10">
        
        <div className="text-center mb-20">
          <h2 className="text-4xl md:text-5xl font-heading font-bold text-[#111827] mb-4">
            Up and running in 3 simple steps
          </h2>
          <p className="text-lg text-gray-600 max-w-2xl mx-auto">
            Zero complex configurations. Get your team dialing and closing deals within minutes.
          </p>
        </div>

        <div className="relative">
          {/* Background Track Line (Desktop: Horizontal, Mobile: Vertical) */}
          <div className="absolute top-[48px] left-8 md:left-[10%] md:right-[10%] h-full md:h-1 w-1 md:w-auto bg-blue-200/50 rounded-full z-0 hidden sm:block">
            {/* Animated Draw Line */}
            <motion.div 
              initial={{ width: 0 }}
              whileInView={{ width: "100%" }}
              viewport={{ once: true, margin: "-100px" }}
              transition={{ duration: 1.5, ease: "easeInOut" }}
              className="absolute top-0 left-0 h-full w-full bg-[#1A6FF5] rounded-full origin-left"
            />
          </div>

          <div className="grid grid-cols-1 md:grid-cols-3 gap-12 md:gap-8 relative z-10">
            {steps.map((step, index) => (
              <motion.div 
                key={index}
                initial={{ opacity: 0, y: 30 }}
                whileInView={{ opacity: 1, y: 0 }}
                viewport={{ once: true, margin: "-50px" }}
                transition={{ delay: index * 0.4, duration: 0.6 }}
                className="flex flex-col items-center text-center relative"
              >
                {/* Step Circle */}
                <div className="w-24 h-24 rounded-full bg-white border-4 border-[#E8F0FD] shadow-xl flex items-center justify-center mb-8 relative group">
                  <step.icon className="w-10 h-10 text-[#1A6FF5] group-hover:scale-110 transition-transform duration-300" />
                  <div className="absolute -top-3 -right-3 w-8 h-8 rounded-full bg-[#0D1B3E] text-white text-sm font-bold flex items-center justify-center border-2 border-[#E8F0FD]">
                    {step.num}
                  </div>
                </div>

                <h3 className="text-2xl font-bold text-[#111827] mb-4">{step.title}</h3>
                <p className="text-gray-600 leading-relaxed max-w-sm">
                  {step.description}
                </p>
                
                {/* Placeholder for the PRD requested mini screenshot */}
                <div className="mt-8 w-full max-w-[280px] h-32 bg-white rounded-xl shadow-sm border border-gray-100 flex items-center justify-center overflow-hidden group">
                  <span className="text-xs text-gray-400 font-medium group-hover:text-[#1A6FF5] transition-colors">
                    [UI Mockup: {step.title}]
                  </span>
                </div>
              </motion.div>
            ))}
          </div>
        </div>

        <motion.div 
          initial={{ opacity: 0, y: 20 }}
          whileInView={{ opacity: 1, y: 0 }}
          viewport={{ once: true }}
          transition={{ delay: 1.2, duration: 0.5 }}
          className="mt-20 text-center"
        >
          <Button size="lg" className="bg-[#1A6FF5] hover:bg-blue-700 text-white rounded-lg px-8 py-6 text-lg shadow-lg">
            See it live — Request a Demo
          </Button>
        </motion.div>

      </div>
    </section>
  )
}