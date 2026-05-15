// components/sections/Industries.tsx
'use client'

import { motion } from 'framer-motion'
import Link from 'next/link'
import {
    Building2, ShieldCheck, Landmark, Headphones,
    Sun, HeartPulse, Plane, Hammer, ArrowRight
} from 'lucide-react'

const industries = [
    { name: 'Real Estate', icon: Building2, stat: '3X more tours booked', slug: 'real-estate' },
    { name: 'Insurance', icon: ShieldCheck, stat: '45% increase in policies', slug: 'insurance' },
    { name: 'Debt Collection', icon: Landmark, stat: '2X faster recovery', slug: 'debt-collection' },
    { name: 'BPO', icon: Headphones, stat: 'Slash idle time by 60%', slug: 'bpo' },
    { name: 'Solar', icon: Sun, stat: 'Double your appointments', slug: 'solar' },
    { name: 'Healthcare', icon: HeartPulse, stat: '100% HIPAA compliant', slug: 'healthcare' },
    { name: 'Travel', icon: Plane, stat: 'Boost upsell rates by 30%', slug: 'travel' },
    { name: 'Home Services', icon: Hammer, stat: 'Fill technician schedules', slug: 'home-services' },
]

export function Industries() {
    return (
        <section className="py-24 bg-white">
            <div className="container mx-auto px-4 max-w-7xl">

                <div className="text-center mb-16">
                    <div className="inline-flex items-center gap-2 px-4 py-1.5 rounded-full bg-gradient-to-r from-[#E8F0FD] to-white border border-[#1A6FF5]/10 shadow-sm text-[#1A6FF5] text-xs font-bold tracking-widest uppercase mb-6">
                        <span className="w-1.5 h-1.5 rounded-full bg-[#1A6FF5] animate-pulse"></span>
                        Industries We Serve
                    </div>
                    <h2 className="text-3xl md:text-5xl font-heading font-bold text-[#111827]">
                        Built for every outbound team
                    </h2>
                </div>

                <div className="grid grid-cols-1 sm:grid-cols-2 lg:grid-cols-4 gap-6">
                    {industries.map((industry, index) => (
                        <motion.div
                            key={index}
                            initial={{ opacity: 0, y: 20 }}
                            whileInView={{ opacity: 1, y: 0 }}
                            viewport={{ once: true, margin: "-50px" }}
                            transition={{ delay: index * 0.1, duration: 0.4 }}
                        >
                            <Link
                                href={`/industries/${industry.slug}`}
                                className="group flex flex-col min-h-[220px] bg-white p-8 rounded-2xl border border-gray-200 shadow-sm transition-all duration-300 hover:bg-[#0D1B3E] hover:border-[#0D1B3E] hover:shadow-xl hover:-translate-y-1 overflow-hidden"
                            >
                                {/* Default State Icon */}
                                <industry.icon className="w-12 h-12 text-[#1A6FF5] mb-6 group-hover:text-white transition-colors duration-300" />

                                <h4 className="text-xl font-bold text-[#111827] group-hover:text-white transition-colors duration-300">
                                    {industry.name}
                                </h4>

                                {/* Spacer container jo bottom links ko neechay push karega */}
                                <div className="relative w-full h-6 mt-auto">
                                    {/* Default Explore Link */}
                                    <div className="absolute inset-0 flex items-center text-sm font-semibold text-gray-500 group-hover:opacity-0 transition-opacity duration-300">
                                        Explore <ArrowRight className="w-4 h-4 ml-1" />
                                    </div>

                                    {/* Hover State: Revealed Stat */}
                                    <div className="absolute inset-0 flex items-center text-sm font-semibold text-[#06B6D4] opacity-0 -translate-y-2 group-hover:opacity-100 group-hover:translate-y-0 transition-all duration-300 whitespace-nowrap">
                                        {industry.stat} <ArrowRight className="w-4 h-4 ml-2 group-hover:translate-x-1 transition-transform" />
                                    </div>
                                </div>
                            </Link>
                        </motion.div>
                    ))}
                </div>

            </div>
        </section>
    )
}