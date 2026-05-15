// components/sections/LiveStats.tsx
'use client'

import { motion } from 'framer-motion'
import CountUp from 'react-countup'
import { useInView } from 'react-intersection-observer'

const stats = [
  { value: 3, suffix: "B+", label: "Calls Processed", source: "All-time platform data" },
  { value: 500, suffix: "+", label: "Active Clients", source: "Across 30+ countries" },
  { value: 99.99, suffix: "%", decimals: 2, label: "Uptime SLA", source: "Guaranteed availability" },
  { value: 5, suffix: "X", label: "Higher Contact Rate", source: "Compared to manual dialing" },
]

export function LiveStats() {
  const { ref, inView } = useInView({
    triggerOnce: true,
    threshold: 0.1, // Trigger when 10% of the section is visible
  })

  return (
    <section className="relative w-full bg-[#0D1B3E] py-24 overflow-hidden border-y border-white/10" ref={ref}>
      {/* Background Gradient Mesh (Subtle) */}
      <div className="absolute inset-0 z-0 opacity-30">
        <div className="absolute top-[-20%] left-[-10%] w-[50%] h-[150%] bg-[#1A6FF5] rounded-full blur-[120px]"></div>
        <div className="absolute bottom-[-20%] right-[-10%] w-[40%] h-[150%] bg-[#06B6D4] rounded-full blur-[120px]"></div>
      </div>

      <div className="container mx-auto px-4 max-w-7xl relative z-10">
        <div className="grid grid-cols-1 sm:grid-cols-2 lg:grid-cols-4 gap-12 text-center divide-y sm:divide-y-0 sm:divide-x divide-white/10">
          {stats.map((stat, index) => (
            <motion.div
              key={index}
              initial={{ opacity: 0, y: 20 }}
              animate={inView ? { opacity: 1, y: 0 } : { opacity: 0, y: 20 }}
              transition={{ delay: index * 0.2, duration: 0.6 }}
              className={`flex flex-col items-center justify-center ${index > 0 ? 'pt-12 sm:pt-0' : ''}`}
            >
              <div className="text-5xl md:text-6xl font-heading font-bold text-white mb-2 tracking-tight">
                {inView ? (
                  <CountUp
                    end={stat.value}
                    decimals={stat.decimals || 0}
                    duration={2.5}
                    useEasing={true}
                  />
                ) : (
                  "0"
                )}
                <span className="text-[#1A6FF5] ml-1">{stat.suffix}</span>
              </div>
              <h3 className="text-lg font-semibold text-blue-100 mb-2">{stat.label}</h3>
              <p className="text-xs text-blue-200/60 uppercase tracking-widest">{stat.source}</p>
            </motion.div>
          ))}
        </div>
      </div>
    </section>
  )
}