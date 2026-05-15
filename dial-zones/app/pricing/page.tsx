// app/pricing/page.tsx
'use client'

import { useState } from 'react'
import { motion } from 'framer-motion'
import { CheckCircle2, X } from 'lucide-react'
import { Button } from '@/components/ui/button'

const tiers = [
    {
        name: "Starter",
        description: "Perfect for small teams just getting started with outbound.",
        monthlyPrice: 49,
        annualPrice: 39,
        features: [
            "Up to 5 agents",
            "Power Dialer included",
            "Standard CRM integrations",
            "Basic reporting",
            "Email support"
        ],
        missingFeatures: [
            "Predictive Dialer",
            "AI Voicebots",
            "Custom API access"
        ],
        cta: "Start Free Trial",
        popular: false
    },
    {
        name: "Professional",
        description: "The complete toolkit for growing call centers.",
        monthlyPrice: 89,
        annualPrice: 75,
        features: [
            "Up to 50 agents",
            "Predictive & Power Dialer",
            "Advanced CRM integrations",
            "Real-time analytics dashboard",
            "24/7 Priority support",
            "Call recording (90 days)"
        ],
        missingFeatures: [
            "AI Voicebots"
        ],
        cta: "Start Free Trial",
        popular: true
    },
    {
        name: "Enterprise",
        description: "Custom solutions for high-volume global operations.",
        monthlyPrice: "Custom",
        annualPrice: "Custom",
        features: [
            "Unlimited agents",
            "AI Voicebots & Screening",
            "Custom API & Webhooks",
            "Dedicated success manager",
            "Custom data retention",
            "SLA guarantee (99.99%)"
        ],
        missingFeatures: [],
        cta: "Contact Sales",
        popular: false
    }
]

const faqs = [
    { q: "Is there a setup fee?", a: "No, Dial Zones is 100% cloud-based. There are zero setup fees or hidden installation charges." },
    { q: "Can I cancel my subscription anytime?", a: "Yes, our monthly plans operate on a month-to-month basis. You can cancel anytime without penalty." },
    { q: "Do you offer VoIP minutes?", a: "Yes, we offer competitive SIP trunking and VoIP minute bundles depending on your calling regions." },
    { q: "Is migration from my current dialer free?", a: "Absolutely. Our onboarding team handles end-to-end data migration from Dialer360, Vicidial, and others at no extra cost for Professional and Enterprise plans." }
]

export default function PricingPage() {
    const [isAnnual, setIsAnnual] = useState(true)

    return (
        <main className="min-h-screen bg-gray-50 pb-24">
            {/* Header */}
            <section className="pt-32 pb-20 bg-[#0D1B3E] text-center text-white">
                <div className="container mx-auto px-4 max-w-4xl">
                    <motion.h1
                        initial={{ opacity: 0, y: -20 }}
                        animate={{ opacity: 1, y: 0 }}
                        className="text-4xl md:text-6xl font-heading font-bold mb-6"
                    >
                        Simple, transparent <span className="text-[#1A6FF5]">pricing</span>
                    </motion.h1>
                    <p className="text-xl text-blue-200 mb-10">
                        No hidden fees. No complex contracts. Scale your team with predictable costs.
                    </p>

                    {/* Billing Toggle */}
                    <div className="flex items-center justify-center gap-4 h-10">
                        <span className={`text-sm font-medium pt-1 ${!isAnnual ? 'text-white' : 'text-blue-300'}`}>Monthly</span>
                        <button
                            onClick={() => setIsAnnual(!isAnnual)}
                            className="relative w-16 h-8 bg-[#1A6FF5] rounded-full p-1 transition-colors flex items-center"
                        >
                            <motion.div
                                className="w-6 h-6 bg-white rounded-full shadow-sm"
                                animate={{ x: isAnnual ? 32 : 0 }}
                                transition={{ type: "spring", stiffness: 500, damping: 30 }}
                            />
                        </button>
                        <span className={`text-sm font-medium flex items-center gap-2 ${isAnnual ? 'text-white' : 'text-blue-300'}`}>
                            Annually <span className="text-xs bg-green-500/20 text-green-400 px-2 py-0.5 rounded-full border border-green-500/30">Save 20%</span>
                        </span>
                    </div>
                </div>
            </section>

            {/* Pricing Cards */}
            <section className="container mx-auto px-4 max-w-7xl -mt-12 relative z-10">
                <div className="grid grid-cols-1 md:grid-cols-3 gap-8 items-start">
                    {tiers.map((tier, index) => (
                        <motion.div
                            key={index}
                            initial={{ opacity: 0, y: 20 }}
                            animate={{ opacity: 1, y: 0 }}
                            transition={{ delay: index * 0.1 }}
                            className={`relative bg-white rounded-3xl border ${tier.popular ? 'border-[#1A6FF5] shadow-2xl shadow-blue-900/5 md:-mt-4 md:mb-4' : 'border-gray-200 shadow-lg'} p-8 flex flex-col`}
                        >
                            {tier.popular && (
                                <div className="absolute top-0 left-1/2 -translate-x-1/2 -translate-y-1/2 bg-[#1A6FF5] text-white text-xs font-bold uppercase tracking-widest py-1.5 px-4 rounded-full border-2 border-white shadow-md">
                                    Most Popular
                                </div>
                            )}

                            <h3 className="text-2xl font-bold text-[#111827] mb-2">{tier.name}</h3>
                            <p className="text-gray-500 text-sm mb-6 min-h-[40px]">{tier.description}</p>

                            <div className="mb-6">
                                {typeof tier.monthlyPrice === 'number' ? (
                                    <div className="flex items-end gap-1">
                                        <span className="text-4xl font-heading font-bold text-[#111827]">
                                            ${isAnnual ? tier.annualPrice : tier.monthlyPrice}
                                        </span>
                                        <span className="text-gray-500 mb-1">/mo per agent</span>
                                    </div>
                                ) : (
                                    <div className="text-4xl font-heading font-bold text-[#111827]">
                                        Custom
                                    </div>
                                )}
                            </div>

                            <Button
                                className={`w-full py-6 text-lg mb-8 ${tier.popular ? 'bg-[#1A6FF5] hover:bg-blue-700 text-white' : 'bg-gray-100 hover:bg-gray-200 text-[#111827]'}`}
                            >
                                {tier.cta}
                            </Button>

                            <div className="flex-1">
                                <p className="text-sm font-bold text-[#111827] uppercase tracking-wider mb-4">What's included</p>
                                <ul className="space-y-4 mb-6">
                                    {tier.features.map((feature, i) => (
                                        <li key={i} className="flex items-start gap-3 text-gray-700 text-sm">
                                            <CheckCircle2 className="w-5 h-5 text-green-500 flex-shrink-0" />
                                            {feature}
                                        </li>
                                    ))}
                                </ul>

                                {tier.missingFeatures.length > 0 && (
                                    <ul className="space-y-4 pt-4 border-t border-gray-100">
                                        {tier.missingFeatures.map((feature, i) => (
                                            <li key={i} className="flex items-start gap-3 text-gray-400 text-sm">
                                                <X className="w-5 h-5 text-gray-300 flex-shrink-0" />
                                                {feature}
                                            </li>
                                        ))}
                                    </ul>
                                )}
                            </div>
                        </motion.div>
                    ))}
                </div>
            </section>

            {/* FAQs */}
            <section className="container mx-auto px-4 max-w-3xl mt-32">
                <h2 className="text-3xl font-heading font-bold text-center text-[#111827] mb-12">Frequently Asked Questions</h2>
                <div className="space-y-6">
                    {faqs.map((faq, index) => (
                        <div key={index} className="bg-white p-6 rounded-2xl border border-gray-200 shadow-sm">
                            <h4 className="text-lg font-bold text-[#111827] mb-2">{faq.q}</h4>
                            <p className="text-gray-600">{faq.a}</p>
                        </div>
                    ))}
                </div>
            </section>
        </main>
    )
}