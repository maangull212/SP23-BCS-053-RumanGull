// components/sections/Integrations.tsx
'use client'

import { motion } from 'framer-motion'
import Link from 'next/link'
import { ArrowRight, Database, Cloud, Zap, MessageSquare, Layers, Mail } from 'lucide-react'

// Dummy data for CRMs (using Lucide icons as placeholders for real logos)
const row1Integrations = [
  { name: 'Salesforce', icon: Cloud, color: 'text-blue-500' },
  { name: 'HubSpot', icon: Database, color: 'text-orange-500' },
  { name: 'Zendesk', icon: MessageSquare, color: 'text-green-600' },
  { name: 'Zoho CRM', icon: Layers, color: 'text-yellow-500' },
  { name: 'Pipedrive', icon: Database, color: 'text-green-500' },
  { name: 'Zapier', icon: Zap, color: 'text-orange-400' },
]

const row2Integrations = [
  { name: 'ActiveCampaign', icon: Mail, color: 'text-blue-600' },
  { name: 'Gohighlevel', icon: Layers, color: 'text-blue-400' },
  { name: 'Keap', icon: Cloud, color: 'text-green-500' },
  { name: 'Freshdesk', icon: MessageSquare, color: 'text-orange-500' },
  { name: 'Monday.com', icon: Layers, color: 'text-red-500' },
  { name: 'Intercom', icon: MessageSquare, color: 'text-blue-500' },
]

export function Integrations() {
  // Seamless loop ke liye array ko 4 dafa repeat kar rahe hain
  const loopRow1 = [...row1Integrations, ...row1Integrations, ...row1Integrations, ...row1Integrations]
  const loopRow2 = [...row2Integrations, ...row2Integrations, ...row2Integrations, ...row2Integrations]

  return (
    <section className="py-24 bg-[#F9FAFB] overflow-hidden">
      <div className="container mx-auto px-4 max-w-7xl mb-16 text-center">
        <h2 className="text-3xl md:text-4xl font-heading font-bold text-[#111827] mb-4">
          Works with the tools your team already uses
        </h2>
        <p className="text-gray-600 text-lg max-w-2xl mx-auto">
          Seamlessly sync leads, log calls, and trigger workflows with 40+ native integrations. No coding required.
        </p>
      </div>

      <div className="relative w-full flex flex-col gap-6">
        {/* Left/Right fading gradients taake smooth entry/exit lagay */}
        <div className="absolute left-0 top-0 bottom-0 w-32 z-10 bg-gradient-to-r from-[#F9FAFB] to-transparent pointer-events-none"></div>
        <div className="absolute right-0 top-0 bottom-0 w-32 z-10 bg-gradient-to-l from-[#F9FAFB] to-transparent pointer-events-none"></div>

        {/* Row 1 (Left to Right) */}
        <div className="flex w-max animate-marquee hover:cursor-pointer items-center py-2">
          {loopRow1.map((tool, index) => (
            <div 
              key={index} 
              className="flex items-center gap-3 px-6 py-4 mx-3 bg-white rounded-xl border border-gray-100 shadow-sm hover:shadow-lg transition-all duration-300 group hover:-translate-y-1"
            >
              <tool.icon className={`w-8 h-8 ${tool.color} group-hover:scale-110 transition-transform`} />
              <span className="text-lg font-bold text-[#111827] font-sans">
                {tool.name}
              </span>
            </div>
          ))}
        </div>

        {/* Row 2 (Right to Left) */}
        <div className="flex w-max animate-marquee-reverse hover:cursor-pointer items-center py-2">
          {loopRow2.map((tool, index) => (
            <div 
              key={index} 
              className="flex items-center gap-3 px-6 py-4 mx-3 bg-white rounded-xl border border-gray-100 shadow-sm hover:shadow-lg transition-all duration-300 group hover:-translate-y-1"
            >
              <tool.icon className={`w-8 h-8 ${tool.color} group-hover:scale-110 transition-transform`} />
              <span className="text-lg font-bold text-[#111827] font-sans">
                {tool.name}
              </span>
            </div>
          ))}
        </div>
      </div>

      <div className="container mx-auto px-4 max-w-7xl mt-16 text-center">
        <Link href="/integrations" className="inline-flex items-center gap-2 text-[#1A6FF5] font-semibold hover:gap-3 transition-all text-lg">
          Browse all 40+ integrations <ArrowRight className="w-5 h-5" />
        </Link>
      </div>
    </section>
  )
}