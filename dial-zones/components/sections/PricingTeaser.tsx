// components/sections/PricingTeaser.tsx
'use client'

import { Button } from '@/components/ui/button'
import { Lock, Shield, Clock } from 'lucide-react'

export function PricingTeaser() {
  return (
    <section className="py-16 bg-[#E8F0FD]">
      <div className="container mx-auto px-4 max-w-7xl">
        <div className="flex flex-col md:flex-row items-center justify-between gap-8 bg-white p-8 md:p-12 rounded-3xl shadow-sm border border-[#1A6FF5]/10">
          
          <div className="flex-1 text-center md:text-left">
            <h2 className="text-3xl md:text-4xl font-heading font-bold text-[#111827] mb-4">
              Plans starting at <span className="text-[#1A6FF5]">$49</span><span className="text-xl text-gray-500 font-sans font-medium">/mo per agent</span>
            </h2>
            <p className="text-lg text-gray-600 font-medium">
              No setup fees. Cancel anytime. Free migration included.
            </p>
          </div>
          
          <div className="flex-1 w-full flex flex-col md:items-end">
            <div className="flex flex-col sm:flex-row gap-4 w-full md:w-auto mb-6">
              <Button size="lg" className="bg-[#1A6FF5] hover:bg-blue-700 hover:scale-105 transition-transform text-white rounded-lg px-8 py-6 text-lg w-full sm:w-auto shadow-lg shadow-blue-500/20">
                Start Free Trial
              </Button>
              <Button size="lg" variant="outline" className="border-2 border-gray-200 hover:bg-gray-50 text-[#111827] rounded-lg px-8 py-6 text-lg w-full sm:w-auto">
                View Full Pricing
              </Button>
            </div>
            
            <div className="flex flex-wrap items-center justify-center md:justify-end gap-5 text-sm text-gray-500 font-medium">
              <span className="flex items-center gap-1.5"><Lock className="w-4 h-4 text-[#1A6FF5]" /> 256-bit SSL</span>
              <span className="flex items-center gap-1.5"><Shield className="w-4 h-4 text-[#1A6FF5]" /> PCI Compliant</span>
              <span className="flex items-center gap-1.5"><Clock className="w-4 h-4 text-[#1A6FF5]" /> Cancel Anytime</span>
            </div>
          </div>

        </div>
      </div>
    </section>
  )
}