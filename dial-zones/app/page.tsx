// app/page.tsx
'use client'

import { motion } from 'framer-motion'
import { Button } from '@/components/ui/button'
import { SocialProof } from '@/components/sections/SocialProof'
import { ProductsGrid } from '@/components/sections/ProductsGrid'
import { HowItWorks } from '@/components/sections/HowItWorks'
import { LiveStats } from '@/components/sections/LiveStats'
import { Benefits } from '@/components/sections/Benefits'
import { Integrations } from '@/components/sections/Integrations'
import { Testimonials } from '@/components/sections/Testimonials'
import { Industries } from '@/components/sections/Industries'
import { PricingTeaser } from '@/components/sections/PricingTeaser'
import { Awards } from '@/components/sections/Awards'
import { FinalCTA } from '@/components/sections/FinalCTA'
import Link from 'next/link'

export default function Home() {
  return (
    <main className="min-h-screen bg-white pt-32 pb-20">
      <div className="container mx-auto px-4 md:px-8 max-w-7xl">
        <div className="flex flex-col lg:flex-row items-center justify-between gap-12 lg:gap-8">

          {/* Left Column: Content */}
          <div className="flex-1 w-full flex flex-col gap-8">
            <motion.div
              initial={{ opacity: 0, y: 20 }}
              animate={{ opacity: 1, y: 0 }}
              transition={{ delay: 0.1, duration: 0.5 }}
            >
              <span className="inline-flex items-center gap-2 px-4 py-2 rounded-full bg-[#E8F0FD] text-[#1A6FF5] text-sm font-semibold mb-6">
                <span className="w-2 h-2 rounded-full bg-[#1A6FF5] animate-pulse"></span>
                AI-Powered Dialing Technology
              </span>

              <h1 className="text-5xl md:text-6xl lg:text-7xl font-bold font-heading text-[#111827] leading-tight mb-6">
                Dial Smarter. <br />
                Convert <span className="text-[#1A6FF5]">Faster.</span> <br />
                Scale Anywhere.
              </h1>

              <p className="text-lg md:text-xl text-gray-600 max-w-xl mb-2">
                The enterprise call center dialer that 500+ businesses trust to double their connect rates and drive global revenue.
              </p>
            </motion.div>

            <motion.div
              initial={{ opacity: 0, y: 20 }}
              animate={{ opacity: 1, y: 0 }}
              transition={{ delay: 0.3, duration: 0.5 }}
              className="flex flex-col sm:flex-row gap-4 items-start sm:items-center"
            >
              <Button asChild className="bg-[#1A6FF5] hover:bg-blue-700 text-white px-8 py-6 rounded-xl font-bold shadow-lg shadow-blue-500/30">
                <Link href="/demo">Get Free Trial</Link>
              </Button>
              <Button size="lg" variant="outline" className="border-2 border-gray-200 text-gray-700 hover:bg-gray-50 rounded-lg px-8 py-6 text-lg w-full sm:w-auto">
                ▶ Watch 2-min Demo
              </Button>
            </motion.div>

            <motion.div
              initial={{ opacity: 0 }}
              animate={{ opacity: 1 }}
              transition={{ delay: 0.5, duration: 0.5 }}
              className="flex items-center gap-4 text-sm text-gray-500 mt-4"
            >
              <div className="flex items-center text-yellow-400">
                {'★'.repeat(5)}
              </div>
              <span>4.9/5 on G2</span>
              <span className="w-1 h-1 bg-gray-300 rounded-full"></span>
              <span>No credit card required</span>
            </motion.div>
          </div>

          {/* Right Column: Visual Mockup Area */}
          <div className="flex-1 w-full relative">
            <motion.div
              initial={{ opacity: 0, scale: 0.95 }}
              animate={{ opacity: 1, scale: 1 }}
              transition={{ delay: 0.4, duration: 0.6 }}
              className="relative w-full aspect-square md:aspect-[4/3] bg-gradient-to-tr from-[#E8F0FD] to-white rounded-2xl border border-gray-100 shadow-2xl flex items-center justify-center overflow-hidden"
            >
              {/* This is a placeholder for your isometric dashboard image */}
              <div className="text-center p-8">
                <div className="w-20 h-20 mx-auto bg-blue-100 rounded-full flex items-center justify-center mb-4">
                  <span className="text-[#1A6FF5] font-bold text-xl">dz</span>
                </div>
                <p className="text-gray-500 font-medium">Isometric Dashboard Mockup Area</p>
                <p className="text-sm text-gray-400 mt-2">(Insert high-res product image here)</p>
              </div>

              {/* Floating Animation Elements (Like PRD requested) */}
              <motion.div
                animate={{ y: [-10, 10, -10] }}
                transition={{ repeat: Infinity, duration: 4, ease: "easeInOut" }}
                className="absolute top-10 -left-6 bg-white p-4 rounded-xl shadow-lg border border-gray-100 flex gap-3 items-center"
              >
                <div className="w-8 h-8 rounded-full bg-green-100 flex items-center justify-center text-green-600">✓</div>
                <div>
                  <p className="text-sm font-bold text-gray-800">Call Connected</p>
                  <p className="text-xs text-gray-500">47% higher conversion</p>
                </div>
              </motion.div>

            </motion.div>
          </div>

        </div>
      </div>
      <SocialProof />
      <ProductsGrid />
      <HowItWorks />
      <LiveStats />
      <Benefits />
      <Integrations />
      <Testimonials />
      <Industries />
      <PricingTeaser />
      <Awards />
      <FinalCTA />
    </main>
  )
}