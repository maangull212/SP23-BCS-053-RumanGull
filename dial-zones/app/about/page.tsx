// app/about/page.tsx
'use client'

import { motion } from 'framer-motion'
import { Globe2, Users, ShieldCheck, Target, Award, ArrowRight } from 'lucide-react'
import Image from 'next/image'
import { Button } from '@/components/ui/button'

const stats = [
  { label: 'Founded', value: '2018' },
  { label: 'Countries Served', value: '30+' },
  { label: 'Daily Calls', value: '15M+' },
  { label: 'Global Team', value: '120+' },
]

const values = [
  {
    title: "Reliability above all",
    description: "When sales are on the line, every second counts. We engineer for 99.99% uptime because downtime is not an option.",
    icon: ShieldCheck
  },
  {
    title: "Global focus, local feel",
    description: "We build tools that let teams scale internationally while maintaining the personalized touch of a local business.",
    icon: Globe2
  },
  {
    title: "Empowering human connection",
    description: "We use AI and automation not to replace agents, but to remove friction so they can focus on what they do best: connecting.",
    icon: Users
  },
  {
    title: "Continuous innovation",
    description: "The telecommunications landscape shifts rapidly. We invest heavily in R&D to ensure our clients are always ahead of the curve.",
    icon: Target
  }
]

const team = [
  { name: 'Sarah Jenkins', role: 'Chief Executive Officer', initial: 'SJ' },
  { name: 'David Chen', role: 'Chief Technology Officer', initial: 'DC' },
  { name: 'Marcus Rowell', role: 'Head of Global Infrastructure', initial: 'MR' },
  { name: 'Elena Rodriguez', role: 'VP of Customer Success', initial: 'ER' },
]

export default function AboutPage() {
  return (
    <main className="min-h-screen bg-white">
      {/* Hero Section */}
      <section className="pt-32 pb-20 bg-[#0D1B3E] text-center text-white">
        <div className="container mx-auto px-4 max-w-4xl">
          <motion.h1 
            initial={{ opacity: 0, y: -20 }}
            animate={{ opacity: 1, y: 0 }}
            className="text-4xl md:text-6xl font-heading font-bold mb-6"
          >
            Humanizing technology at <span className="text-[#1A6FF5]">scale</span>
          </motion.h1>
          <p className="text-xl text-blue-200 leading-relaxed">
            We started Dial Zones with a simple premise: outbound teams deserve enterprise-grade software that is powerful, transparent, and easy to use.
          </p>
        </div>
      </section>

      {/* Stats Bar */}
      <section className="bg-[#1A6FF5] py-12">
        <div className="container mx-auto px-4 max-w-6xl">
          <div className="grid grid-cols-2 md:grid-cols-4 gap-8 text-center divide-x-0 md:divide-x divide-blue-400/30">
            {stats.map((stat, index) => (
              <motion.div 
                key={index}
                initial={{ opacity: 0, y: 20 }}
                whileInView={{ opacity: 1, y: 0 }}
                viewport={{ once: true }}
                transition={{ delay: index * 0.1 }}
                className="flex flex-col items-center"
              >
                <div className="text-4xl md:text-5xl font-heading font-bold text-white mb-2">{stat.value}</div>
                <div className="text-sm font-semibold text-blue-100 uppercase tracking-widest">{stat.label}</div>
              </motion.div>
            ))}
          </div>
        </div>
      </section>

      {/* Mission & Values */}
      <section className="py-24 bg-gray-50">
        <div className="container mx-auto px-4 max-w-7xl">
          <div className="text-center mb-16">
            <h2 className="text-3xl md:text-4xl font-heading font-bold text-[#111827] mb-4">Our Core Values</h2>
            <p className="text-gray-600 max-w-2xl mx-auto">These principles guide every feature we build and every support ticket we answer.</p>
          </div>

          <div className="grid grid-cols-1 md:grid-cols-2 gap-8">
            {values.map((value, index) => (
              <motion.div 
                key={index}
                initial={{ opacity: 0, y: 20 }}
                whileInView={{ opacity: 1, y: 0 }}
                viewport={{ once: true }}
                transition={{ delay: index * 0.1 }}
                className="bg-white p-8 rounded-2xl border border-gray-100 shadow-sm flex items-start gap-6"
              >
                <div className="w-12 h-12 rounded-xl bg-blue-50 text-[#1A6FF5] flex items-center justify-center flex-shrink-0">
                  <value.icon className="w-6 h-6" />
                </div>
                <div>
                  <h3 className="text-xl font-bold text-[#111827] mb-2">{value.title}</h3>
                  <p className="text-gray-600 leading-relaxed">{value.description}</p>
                </div>
              </motion.div>
            ))}
          </div>
        </div>
      </section>

      {/* Team Section */}
      <section className="py-24 bg-white border-b border-gray-100">
        <div className="container mx-auto px-4 max-w-7xl">
          <div className="text-center mb-16">
            <h2 className="text-3xl md:text-4xl font-heading font-bold text-[#111827] mb-4">Leadership Team</h2>
            <p className="text-gray-600 max-w-2xl mx-auto">Backed by decades of experience in telecommunications, distributed systems, and enterprise B2B support.</p>
          </div>

          <div className="grid grid-cols-1 sm:grid-cols-2 lg:grid-cols-4 gap-8">
            {team.map((member, index) => (
              <motion.div 
                key={index}
                initial={{ opacity: 0, scale: 0.95 }}
                whileInView={{ opacity: 1, scale: 1 }}
                viewport={{ once: true }}
                transition={{ delay: index * 0.1 }}
                className="group"
              >
                <div className="aspect-square bg-gray-100 rounded-2xl mb-6 overflow-hidden flex items-center justify-center bg-gradient-to-br from-gray-100 to-gray-200">
                  <span className="text-4xl font-bold text-gray-400 group-hover:scale-110 transition-transform duration-300">{member.initial}</span>
                </div>
                <h3 className="text-xl font-bold text-[#111827] text-center">{member.name}</h3>
                <p className="text-[#1A6FF5] font-medium text-center text-sm">{member.role}</p>
              </motion.div>
            ))}
          </div>
        </div>
      </section>

      {/* CTA */}
      <section className="py-20 bg-[#F9FAFB] text-center">
        <div className="container mx-auto px-4 max-w-3xl">
          <h2 className="text-3xl font-heading font-bold text-[#111827] mb-6">Ready to join the dialing revolution?</h2>
          <Button size="lg" className="bg-[#1A6FF5] hover:bg-blue-700 text-white px-8 py-6 rounded-xl font-bold shadow-lg shadow-blue-500/30">
            Talk to our team
          </Button>
        </div>
      </section>
    </main>
  )
}