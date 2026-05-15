// components/sections/ProductsGrid.tsx
'use client'

import { motion } from 'framer-motion'
import { PhoneOutgoing, Sparkles, Zap, PhoneForwarded, Voicemail, Server } from 'lucide-react'

const products = [
    {
        title: "Predictive Dialer",
        description: "Connect agents to live calls instantly. Algorithm predicts when agents will be free.",
        icon: PhoneOutgoing,
        colSpan: "md:col-span-2 lg:col-span-2"
    },
    {
        title: "AI Dialer",
        description: "Smart voicebots handle initial screening and routing.",
        icon: Sparkles,
        colSpan: "md:col-span-1 lg:col-span-1"
    },
    {
        title: "Power Dialer",
        description: "Automate list dialing without manual effort.",
        icon: Zap,
        colSpan: "md:col-span-1 lg:col-span-1"
    },
    {
        title: "Auto Dialer",
        description: "Broadcast messages to thousands in minutes.",
        icon: PhoneForwarded,
        colSpan: "md:col-span-2 lg:col-span-1"
    },
    {
        title: "Ringless Voicemail",
        description: "Drop messages directly without ringing.",
        icon: Voicemail,
        colSpan: "md:col-span-1 lg:col-span-1"
    },
    {
        title: "Hosted PBX",
        description: "Cloud-based phone system for entire teams.",
        icon: Server,
        colSpan: "md:col-span-1 lg:col-span-1"
    }
]

export function ProductsGrid() {
    return (
        <section className="py-24 bg-gray-50">
            <div className="container mx-auto px-4 max-w-7xl">

                <div className="mb-16">
                    <div className="inline-flex items-center gap-2 px-4 py-1.5 rounded-full bg-gradient-to-r from-[#E8F0FD] to-white border border-[#1A6FF5]/10 shadow-sm text-[#1A6FF5] text-xs font-bold tracking-widest uppercase mb-6">
                        <span className="w-1.5 h-1.5 rounded-full bg-[#1A6FF5] animate-pulse"></span>
                        Our Products
                    </div>
                    <h2 className="text-4xl md:text-5xl font-heading font-bold text-[#111827]">
                        Built for scale. Designed for speed.
                    </h2>
                </div>

                <div className="grid grid-cols-1 md:grid-cols-3 lg:grid-cols-4 gap-6">
                    {products.map((product, index) => (
                        <motion.div
                            key={index}
                            initial={{ opacity: 0, y: 20 }}
                            whileInView={{ opacity: 1, y: 0 }}
                            viewport={{ once: true }}
                            transition={{ delay: index * 0.1, duration: 0.5 }}
                            className={`group bg-white p-8 rounded-2xl border border-gray-200 hover:border-[#1A6FF5]/30 hover:shadow-xl hover:-translate-y-1 transition-all duration-300 flex flex-col justify-between ${product.colSpan}`}
                        >
                            <div>
                                <div className="w-12 h-12 rounded-xl bg-[#E8F0FD] text-[#1A6FF5] flex items-center justify-center mb-6 group-hover:scale-110 transition-transform">
                                    <product.icon className="w-6 h-6" />
                                </div>
                                <h3 className="text-xl font-bold text-[#111827] mb-3">{product.title}</h3>
                                <p className="text-gray-600 leading-relaxed mb-6">{product.description}</p>
                            </div>

                            <div className="flex items-center text-[#1A6FF5] font-semibold text-sm">
                                Explore feature <span className="ml-2 group-hover:translate-x-1 transition-transform">→</span>
                            </div>
                        </motion.div>
                    ))}
                </div>
            </div>
        </section>
    )
}