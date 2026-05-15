// components/sections/SocialProof.tsx
'use client'

import { motion } from 'framer-motion'
import { Building2, Globe2, Briefcase, Landmark, MonitorSmartphone, Headphones } from 'lucide-react'

// Dummy logos for now - hum inhein baad mein SVGs se replace karenge
const logos = [
  { name: 'TechFlow', icon: MonitorSmartphone },
  { name: 'GlobalFin', icon: Landmark },
  { name: 'ConnectBPO', icon: Headphones },
  { name: 'PropertyHub', icon: Building2 },
  { name: 'Worldwide', icon: Globe2 },
  { name: 'EnterpriseHQ', icon: Briefcase },
]

export function SocialProof() {
  // Array ko double kar rahe hain taake seamless infinite loop ban sake
  const duplicatedLogos = [...logos, ...logos, ...logos]

  return (
    <section className="w-full bg-[#0D1B3E] py-5 overflow-hidden border-y border-white/10">
      <div className="container mx-auto px-4 max-w-7xl mb-4">
        <p className="text-center text-sm font-medium text-blue-200 tracking-wider uppercase">
          Trusted by 500+ call centers in 30+ countries
        </p>
      </div>

      <div className="relative w-full flex">
        {/* Left/Right fading gradients taake smooth entry/exit lagay */}
        <div className="absolute left-0 top-0 bottom-0 w-24 z-10 bg-gradient-to-r from-[#0D1B3E] to-transparent"></div>
        <div className="absolute right-0 top-0 bottom-0 w-24 z-10 bg-gradient-to-l from-[#0D1B3E] to-transparent"></div>

        {/* The Marquee Track */}
        <div className="flex w-max animate-marquee hover:cursor-pointer items-center">
          {duplicatedLogos.map((Company, index) => (
            <div 
              key={index} 
              className="flex items-center gap-3 px-12 opacity-50 hover:opacity-100 transition-opacity duration-300 grayscale hover:grayscale-0"
            >
              <Company.icon className="w-8 h-8 text-white" />
              <span className="text-xl font-bold text-white font-heading tracking-tight">
                {Company.name}
              </span>
            </div>
          ))}
        </div>
      </div>
    </section>
  )
}