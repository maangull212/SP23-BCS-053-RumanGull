// components/sections/Benefits.tsx
'use client'

import { motion } from 'framer-motion'
import { CheckCircle2, ArrowRight, ShieldCheck, Lock, Server } from 'lucide-react'
import Link from 'next/link'

export function Benefits() {
  return (
    <section className="py-24 bg-white overflow-hidden">
      <div className="container mx-auto px-4 max-w-7xl flex flex-col gap-24">
        
        {/* Row 1: Image Left, Text Right */}
        <div className="flex flex-col md:flex-row items-center gap-12 lg:gap-20">
          <motion.div 
            initial={{ opacity: 0, x: -50 }}
            whileInView={{ opacity: 1, x: 0 }}
            viewport={{ once: true, margin: "-100px" }}
            transition={{ duration: 0.6 }}
            className="flex-1 w-full"
          >
            {/* UI Mockup Placeholder */}
            <div className="aspect-video bg-[#E8F0FD] rounded-2xl border border-[#1A6FF5]/10 shadow-lg flex items-center justify-center group relative overflow-hidden">
              <div className="absolute inset-0 bg-gradient-to-tr from-[#1A6FF5]/5 to-transparent"></div>
              <div className="bg-white p-6 rounded-xl shadow-sm border border-gray-100 group-hover:-translate-y-2 transition-transform duration-500">
                <span className="text-[#1A6FF5] font-semibold flex items-center gap-2">
                  <span className="w-2 h-2 rounded-full bg-green-500 animate-pulse"></span>
                  Live Campaign Dashboard
                </span>
              </div>
            </div>
          </motion.div>
          
          <motion.div 
            initial={{ opacity: 0, x: 50 }}
            whileInView={{ opacity: 1, x: 0 }}
            viewport={{ once: true, margin: "-100px" }}
            transition={{ duration: 0.6 }}
            className="flex-1 w-full"
          >
            <h2 className="text-3xl md:text-4xl font-heading font-bold text-[#111827] mb-6">
              5X Faster Dialing with Intelligent Routing
            </h2>
            <p className="text-gray-600 text-lg mb-8">
              Eliminate manual dialing and dead air. Our predictive algorithm analyzes answer rates in real-time, connecting your agents only to live prospects.
            </p>
            <ul className="flex flex-col gap-4 mb-8">
              {['Automated voicemail drop', 'Dynamic lead prioritization', 'Local presence caller ID'].map((bullet, i) => (
                <li key={i} className="flex items-center gap-3 text-gray-700 font-medium">
                  <CheckCircle2 className="w-6 h-6 text-[#1A6FF5] flex-shrink-0 bg-blue-50 rounded-full" />
                  {bullet}
                </li>
              ))}
            </ul>
            <Link href="/features" className="inline-flex items-center gap-2 text-[#1A6FF5] font-semibold hover:gap-3 transition-all">
              Learn more about our dialers <ArrowRight className="w-5 h-5" />
            </Link>
          </motion.div>
        </div>

        {/* Row 2: Text Left, Image Right */}
        <div className="flex flex-col md:flex-row-reverse items-center gap-12 lg:gap-20">
          <motion.div 
            initial={{ opacity: 0, x: 50 }}
            whileInView={{ opacity: 1, x: 0 }}
            viewport={{ once: true, margin: "-100px" }}
            transition={{ duration: 0.6 }}
            className="flex-1 w-full"
          >
            <div className="aspect-video bg-gray-50 rounded-2xl border border-gray-200 shadow-lg flex items-center justify-center group relative overflow-hidden">
              <div className="bg-white p-6 rounded-xl shadow-sm border border-gray-100 group-hover:scale-105 transition-transform duration-500 text-center">
                <div className="text-4xl font-bold text-[#111827] mb-1">99.99%</div>
                <div className="text-sm text-gray-500 font-medium uppercase tracking-wider">System Uptime</div>
              </div>
            </div>
          </motion.div>
          
          <motion.div 
            initial={{ opacity: 0, x: -50 }}
            whileInView={{ opacity: 1, x: 0 }}
            viewport={{ once: true, margin: "-100px" }}
            transition={{ duration: 0.6 }}
            className="flex-1 w-full"
          >
            <h2 className="text-3xl md:text-4xl font-heading font-bold text-[#111827] mb-6">
              Enterprise-Grade Reliability
            </h2>
            <p className="text-gray-600 text-lg mb-8">
              When sales are on the line, downtime is not an option. Our global server infrastructure ensures crystal-clear voice quality and uninterrupted service, 24/7.
            </p>
            <ul className="flex flex-col gap-4 mb-8">
              {['Geographically redundant servers', 'Tier-1 carrier networks', 'Automated failover routing'].map((bullet, i) => (
                <li key={i} className="flex items-center gap-3 text-gray-700 font-medium">
                  <CheckCircle2 className="w-6 h-6 text-[#1A6FF5] flex-shrink-0 bg-blue-50 rounded-full" />
                  {bullet}
                </li>
              ))}
            </ul>
            <Link href="/about" className="inline-flex items-center gap-2 text-[#1A6FF5] font-semibold hover:gap-3 transition-all">
              View our infrastructure <ArrowRight className="w-5 h-5" />
            </Link>
          </motion.div>
        </div>

        {/* Row 3: Image Left, Text Right */}
        <div className="flex flex-col md:flex-row items-center gap-12 lg:gap-20">
          <motion.div 
            initial={{ opacity: 0, x: -50 }}
            whileInView={{ opacity: 1, x: 0 }}
            viewport={{ once: true, margin: "-100px" }}
            transition={{ duration: 0.6 }}
            className="flex-1 w-full"
          >
            <div className="aspect-video bg-[#0D1B3E] rounded-2xl shadow-lg flex items-center justify-center p-8 group">
              <div className="grid grid-cols-2 gap-4 w-full">
                <div className="bg-white/10 rounded-xl p-4 flex flex-col items-center justify-center border border-white/20 text-white backdrop-blur-sm">
                  <ShieldCheck className="w-8 h-8 mb-2 text-blue-400" />
                  <span className="font-bold">PCI DSS</span>
                </div>
                <div className="bg-white/10 rounded-xl p-4 flex flex-col items-center justify-center border border-white/20 text-white backdrop-blur-sm">
                  <Lock className="w-8 h-8 mb-2 text-blue-400" />
                  <span className="font-bold">GDPR Ready</span>
                </div>
                <div className="bg-white/10 rounded-xl p-4 flex flex-col items-center justify-center border border-white/20 text-white backdrop-blur-sm col-span-2">
                  <Server className="w-8 h-8 mb-2 text-blue-400" />
                  <span className="font-bold">TPS / DNC Filtering</span>
                </div>
              </div>
            </div>
          </motion.div>
          
          <motion.div 
            initial={{ opacity: 0, x: 50 }}
            whileInView={{ opacity: 1, x: 0 }}
            viewport={{ once: true, margin: "-100px" }}
            transition={{ duration: 0.6 }}
            className="flex-1 w-full"
          >
            <h2 className="text-3xl md:text-4xl font-heading font-bold text-[#111827] mb-6">
              Full Compliance Built In
            </h2>
            <p className="text-gray-600 text-lg mb-8">
              Protect your business from heavy fines. Our platform automatically scrubs leads against DNC lists and ensures every call adheres to local regulations.
            </p>
            <ul className="flex flex-col gap-4 mb-8">
              {['Automated TPS/CTPS checking', 'Secure call recording & storage', 'Customizable compliance scripts'].map((bullet, i) => (
                <li key={i} className="flex items-center gap-3 text-gray-700 font-medium">
                  <CheckCircle2 className="w-6 h-6 text-[#1A6FF5] flex-shrink-0 bg-blue-50 rounded-full" />
                  {bullet}
                </li>
              ))}
            </ul>
            <Link href="/security" className="inline-flex items-center gap-2 text-[#1A6FF5] font-semibold hover:gap-3 transition-all">
              Read our security standards <ArrowRight className="w-5 h-5" />
            </Link>
          </motion.div>
        </div>

      </div>
    </section>
  )
}