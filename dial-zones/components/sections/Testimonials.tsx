// components/sections/Testimonials.tsx
'use client'

import { motion } from 'framer-motion'
import { Star, BadgeCheck } from 'lucide-react'

// Dummy data looking like real enterprise clients
const testimonials = [
  {
    quote: "Switching to Dial Zones was the best decision for our outbound team. Our connect rates jumped by 47% in the first two weeks alone. The predictive algorithm is incredibly accurate.",
    name: "Sarah Jenkins",
    role: "VP of Sales",
    company: "Apex Global BPO",
    source: "G2",
  },
  {
    quote: "The compliance features let me sleep at night. Knowing that TPS and DNC filtering are handled automatically across 30+ countries saves us from massive potential fines.",
    name: "Michael Chen",
    role: "Operations Director",
    company: "SecureDebt Collections",
    source: "Capterra",
  },
  {
    quote: "We migrated 150 agents from Dialer360 to Dial Zones. The transition was flawless, and the real-time analytics dashboard gives us insights we never had before.",
    name: "Elena Rodriguez",
    role: "Call Center Manager",
    company: "SunPower Solutions",
    source: "G2",
  },
  {
    quote: "The Salesforce integration works exactly as advertised. Calls are logged instantly, and our reps don't have to switch tabs. It saves each rep about an hour a day.",
    name: "David Smith",
    role: "Tech Stack Administrator",
    company: "RealtyCorp UK",
    source: "G2",
  },
  {
    quote: "Customer support is phenomenal. We had a custom routing requirement and their engineering team had a solution deployed within 48 hours. Unheard of in this industry.",
    name: "James Wilson",
    role: "CEO",
    company: "LeadGen Masters",
    source: "Capterra",
  },
  {
    quote: "Drop the manual dialing. The Power Dialer feature here is so smooth. Our agents are having 3x more conversations daily without feeling burnt out.",
    name: "Amanda Foster",
    role: "Inside Sales Director",
    company: "HealthFirst Insurance",
    source: "G2",
  }
]

export function Testimonials() {
  return (
    <section className="py-24 bg-[#0D1B3E] overflow-hidden">
      <div className="container mx-auto px-4 max-w-7xl">
        
        {/* Header Section */}
        <div className="flex flex-col items-center text-center mb-16">
          <h2 className="text-4xl md:text-5xl font-heading font-bold text-white mb-6">
            Don't take our word for it
          </h2>
          <div className="flex flex-col sm:flex-row items-center gap-6 bg-white/5 px-6 py-3 rounded-full border border-white/10">
            <div className="flex items-center gap-2">
              <span className="text-white font-bold">4.9/5</span>
              <div className="flex text-yellow-400">
                {[...Array(5)].map((_, i) => <Star key={i} className="w-4 h-4 fill-current" />)}
              </div>
              <span className="text-gray-400 text-sm ml-1">on G2</span>
            </div>
            <div className="hidden sm:block w-px h-6 bg-white/20"></div>
            <div className="flex items-center gap-2">
              <span className="text-white font-bold">4.8/5</span>
              <div className="flex text-yellow-400">
                {[...Array(5)].map((_, i) => <Star key={i} className="w-4 h-4 fill-current" />)}
              </div>
              <span className="text-gray-400 text-sm ml-1">on Capterra</span>
            </div>
          </div>
        </div>

        {/* Masonry Grid */}
        <div className="columns-1 md:columns-2 lg:columns-3 gap-6 space-y-6">
          {testimonials.map((t, index) => (
            <motion.div
              key={index}
              initial={{ opacity: 0, y: 20 }}
              whileInView={{ opacity: 1, y: 0 }}
              viewport={{ once: true, margin: "-50px" }}
              transition={{ delay: index * 0.1, duration: 0.5 }}
              className="break-inside-avoid bg-white p-8 rounded-2xl border border-gray-100 shadow-sm hover:shadow-lg transition-shadow"
            >
              <div className="flex items-center justify-between mb-6">
                <div className="flex text-yellow-400">
                  {[...Array(5)].map((_, i) => <Star key={i} className="w-5 h-5 fill-current" />)}
                </div>
                <div className="flex items-center gap-1 text-xs font-bold text-gray-500 uppercase tracking-wider bg-gray-50 px-2 py-1 rounded">
                  <BadgeCheck className="w-4 h-4 text-blue-500" />
                  {t.source}
                </div>
              </div>
              
              <p className="text-gray-700 text-lg mb-8 leading-relaxed">
                "{t.quote}"
              </p>
              
              <div className="flex items-center gap-4">
                {/* Fallback Avatar */}
                <div className="w-12 h-12 rounded-full bg-[#E8F0FD] flex items-center justify-center text-[#1A6FF5] font-bold text-lg">
                  {t.name.charAt(0)}
                </div>
                <div>
                  <div className="font-bold text-[#111827]">{t.name}</div>
                  <div className="text-sm text-gray-500">{t.role}, <span className="text-[#1A6FF5]">{t.company}</span></div>
                </div>
              </div>
            </motion.div>
          ))}
        </div>

      </div>
    </section>
  )
}