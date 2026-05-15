// components/sections/Awards.tsx
'use client'

import { motion } from 'framer-motion'
import { ShieldCheck, Award, CheckCircle2 } from 'lucide-react'

const awards = [
  { name: "Top Performer 2025", platform: "Capterra", icon: Award },
  { name: "Best Usability 2026", platform: "G2", icon: Award },
  { name: "Leader Winter 2025", platform: "G2", icon: Award },
  { name: "PCI DSS Certified", platform: "Compliance", icon: ShieldCheck },
  { name: "SOC 2 Type II", platform: "Security", icon: CheckCircle2 },
]

export function Awards() {
  return (
    <section className="py-12 bg-white border-b border-gray-100">
      <div className="container mx-auto px-4 max-w-7xl text-center">
        <h3 className="text-xs font-bold tracking-widest text-gray-400 uppercase mb-8">
          Recognized by industry leaders & fully compliant
        </h3>
        
        <div className="flex flex-wrap justify-center items-center gap-8 md:gap-12">
          {awards.map((award, index) => (
            <motion.div 
              key={index}
              initial={{ opacity: 0, y: 10 }}
              whileInView={{ opacity: 1, y: 0 }}
              viewport={{ once: true }}
              transition={{ delay: index * 0.1 }}
              className="flex items-center gap-3 grayscale opacity-60 hover:grayscale-0 hover:opacity-100 transition-all duration-300 cursor-pointer"
            >
              <div className="w-12 h-12 rounded-full bg-blue-50 flex items-center justify-center">
                <award.icon className="w-6 h-6 text-[#1A6FF5]" />
              </div>
              <div className="text-left hidden sm:block">
                <p className="text-[#111827] font-bold text-sm leading-tight">{award.name}</p>
                <p className="text-gray-500 text-xs">{award.platform}</p>
              </div>
            </motion.div>
          ))}
        </div>
      </div>
    </section>
  )
}