// app/demo/page.tsx
'use client'

import { motion } from 'framer-motion'
import { CheckCircle2, Star, Shield, Clock, ArrowRight } from 'lucide-react'
import { Button } from '@/components/ui/button'

export default function DemoPage() {
  return (
    <main className="min-h-screen bg-white pt-32 pb-24">
      <div className="container mx-auto px-4 max-w-7xl">
        
        {/* Header */}
        <div className="text-center max-w-3xl mx-auto mb-16">
          <motion.h1 
            initial={{ opacity: 0, y: -20 }}
            animate={{ opacity: 1, y: 0 }}
            className="text-4xl md:text-5xl font-heading font-bold text-[#0D1B3E] mb-6"
          >
            See Dial Zones in action
          </motion.h1>
          <p className="text-xl text-gray-600">
            Book a personalized walkthrough with our product experts and see how we can double your connect rates.
          </p>
        </div>

        <div className="flex flex-col lg:flex-row gap-16 items-start">
          
          {/* Left Column: Form (55%) */}
          <motion.div 
            initial={{ opacity: 0, x: -30 }}
            animate={{ opacity: 1, x: 0 }}
            transition={{ delay: 0.1 }}
            className="w-full lg:w-[55%] bg-white p-8 md:p-12 rounded-3xl border border-gray-200 shadow-xl"
          >
            <form className="space-y-6" onSubmit={(e) => e.preventDefault()}>
              <div className="grid grid-cols-1 md:grid-cols-2 gap-6">
                <div className="space-y-2">
                  <label className="text-sm font-semibold text-gray-700">First Name <span className="text-red-500">*</span></label>
                  <input type="text" required className="w-full px-4 py-3 rounded-lg border border-gray-200 focus:ring-2 focus:ring-[#1A6FF5] focus:border-transparent outline-none transition-all" />
                </div>
                <div className="space-y-2">
                  <label className="text-sm font-semibold text-gray-700">Last Name <span className="text-red-500">*</span></label>
                  <input type="text" required className="w-full px-4 py-3 rounded-lg border border-gray-200 focus:ring-2 focus:ring-[#1A6FF5] focus:border-transparent outline-none transition-all" />
                </div>
              </div>

              <div className="grid grid-cols-1 md:grid-cols-2 gap-6">
                <div className="space-y-2">
                  <label className="text-sm font-semibold text-gray-700">Work Email <span className="text-red-500">*</span></label>
                  <input type="email" required className="w-full px-4 py-3 rounded-lg border border-gray-200 focus:ring-2 focus:ring-[#1A6FF5] focus:border-transparent outline-none transition-all" />
                </div>
                <div className="space-y-2">
                  <label className="text-sm font-semibold text-gray-700">Phone Number <span className="text-red-500">*</span></label>
                  <input type="tel" required className="w-full px-4 py-3 rounded-lg border border-gray-200 focus:ring-2 focus:ring-[#1A6FF5] focus:border-transparent outline-none transition-all" />
                </div>
              </div>

              <div className="space-y-2">
                <label className="text-sm font-semibold text-gray-700">Company Name <span className="text-red-500">*</span></label>
                <input type="text" required className="w-full px-4 py-3 rounded-lg border border-gray-200 focus:ring-2 focus:ring-[#1A6FF5] focus:border-transparent outline-none transition-all" />
              </div>

              <div className="grid grid-cols-1 md:grid-cols-2 gap-6">
                <div className="space-y-2">
                  <label className="text-sm font-semibold text-gray-700">Number of Agents</label>
                  <select className="w-full px-4 py-3 rounded-lg border border-gray-200 focus:ring-2 focus:ring-[#1A6FF5] focus:border-transparent outline-none transition-all bg-white">
                    <option value="">Select team size</option>
                    <option value="1-10">1-10 agents</option>
                    <option value="11-50">11-50 agents</option>
                    <option value="51-200">51-200 agents</option>
                    <option value="201+">201+ agents</option>
                  </select>
                </div>
                <div className="space-y-2">
                  <label className="text-sm font-semibold text-gray-700">Primary Use Case</label>
                  <select className="w-full px-4 py-3 rounded-lg border border-gray-200 focus:ring-2 focus:ring-[#1A6FF5] focus:border-transparent outline-none transition-all bg-white">
                    <option value="">Select use case</option>
                    <option value="outbound">Outbound Sales</option>
                    <option value="debt">Debt Collection</option>
                    <option value="real-estate">Real Estate</option>
                    <option value="other">Other</option>
                  </select>
                </div>
              </div>

              <Button className="w-full bg-[#1A6FF5] hover:bg-blue-700 text-white py-7 text-lg font-bold rounded-xl shadow-lg shadow-blue-500/20 mt-4">
                Book My Demo
              </Button>
              
              <div className="flex items-center justify-center gap-2 text-sm text-gray-500 mt-4">
                <Clock className="w-4 h-4 text-[#1A6FF5]" />
                <span>We typically respond within 2 business hours.</span>
              </div>
            </form>
          </motion.div>

          {/* Right Column: Info & Trust Signals (45%) */}
          <motion.div 
            initial={{ opacity: 0, x: 30 }}
            animate={{ opacity: 1, x: 0 }}
            transition={{ delay: 0.2 }}
            className="w-full lg:w-[45%] space-y-10"
          >
            {/* What to expect */}
            <div>
              <h3 className="text-2xl font-bold text-[#111827] mb-6">What to expect in your demo</h3>
              <ul className="space-y-5">
                {[
                  "A brief discussion about your current setup and pain points.",
                  "A live walkthrough of the Dial Zones platform tailored to your industry.",
                  "Deep dive into our AI predictive pacing and CRM integrations.",
                  "Pricing overview and Q&A with a dialing expert."
                ].map((item, i) => (
                  <li key={i} className="flex items-start gap-3">
                    <CheckCircle2 className="w-6 h-6 text-[#1A6FF5] flex-shrink-0" />
                    <span className="text-gray-700 leading-relaxed">{item}</span>
                  </li>
                ))}
              </ul>
            </div>

            {/* Testimonials */}
            <div className="bg-gray-50 p-8 rounded-3xl border border-gray-100">
              <div className="flex items-center gap-1 mb-4 text-[#F59E0B]">
                <Star className="w-5 h-5 fill-current" /><Star className="w-5 h-5 fill-current" /><Star className="w-5 h-5 fill-current" /><Star className="w-5 h-5 fill-current" /><Star className="w-5 h-5 fill-current" />
              </div>
              <blockquote className="text-lg text-gray-700 italic mb-6">
                "The demo was incredibly insightful. We switched from our old dialer the next day and have seen a 40% increase in daily connects since."
              </blockquote>
              <div className="flex items-center gap-4">
                <div className="w-12 h-12 bg-blue-100 rounded-full flex items-center justify-center text-[#1A6FF5] font-bold">MJ</div>
                <div>
                  <p className="font-bold text-[#111827]">Michael Johnson</p>
                  <p className="text-sm text-gray-500">VP of Sales, Apex Solutions</p>
                </div>
              </div>
            </div>

            {/* Trust Bar */}
            <div className="flex items-center gap-6 pt-6 border-t border-gray-100">
              <div className="flex items-center gap-2">
                <Shield className="w-6 h-6 text-green-500" />
                <span className="text-sm font-bold text-gray-700 uppercase tracking-wider">PCI Compliant</span>
              </div>
              <div className="h-6 w-px bg-gray-200"></div>
              <div className="text-sm font-semibold text-gray-600">
                <span className="text-[#111827] font-bold">500+</span> demos completed this month
              </div>
            </div>
          </motion.div>

        </div>
      </div>
    </main>
  )
}