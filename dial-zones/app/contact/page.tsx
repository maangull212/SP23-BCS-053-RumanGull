// app/contact/page.tsx
'use client'

import { motion } from 'framer-motion'
import { Mail, Phone, MapPin, MessageSquare, Clock, ArrowRight } from 'lucide-react'
import { Button } from '@/components/ui/button'

export default function ContactPage() {
    return (
        <main className="min-h-screen bg-gray-50 pb-24">
            {/* Header */}
            <section className="pt-32 pb-16 bg-[#0D1B3E] text-center text-white">
                <div className="container mx-auto px-4 max-w-4xl">
                    <motion.h1
                        initial={{ opacity: 0, y: -20 }}
                        animate={{ opacity: 1, y: 0 }}
                        className="text-4xl md:text-5xl font-heading font-bold mb-4"
                    >
                        Get in touch with our team
                    </motion.h1>
                    <p className="text-xl text-blue-200">
                        Whether you need a custom enterprise demo or have a technical question, we're here to help.
                    </p>
                </div>
            </section>

            <section className="container mx-auto px-4 max-w-7xl -mt-8 relative z-10">
                <div className="flex flex-col lg:flex-row gap-8">

                    {/* Left Column: Contact Info */}
                    <motion.div
                        initial={{ opacity: 0, x: -30 }}
                        animate={{ opacity: 1, x: 0 }}
                        transition={{ delay: 0.1 }}
                        className="flex-1 space-y-6"
                    >
                        {/* Direct Contact Card */}
                        <div className="bg-white p-8 rounded-3xl border border-gray-200 shadow-sm">
                            <h3 className="text-xl font-bold text-[#111827] mb-6">Direct Contact</h3>

                            <div className="space-y-6">
                                <div className="flex items-start gap-4">
                                    <div className="w-10 h-10 rounded-full bg-blue-50 flex items-center justify-center text-[#1A6FF5] flex-shrink-0">
                                        <Phone className="w-5 h-5" />
                                    </div>
                                    <div>
                                        <p className="text-sm font-semibold text-gray-500 uppercase tracking-wider mb-1">Sales (US)</p>
                                        <p className="text-[#111827] font-medium">+1 (800) 123-4567</p>
                                    </div>
                                </div>

                                <div className="flex items-start gap-4">
                                    <div className="w-10 h-10 rounded-full bg-blue-50 flex items-center justify-center text-[#1A6FF5] flex-shrink-0">
                                        <Phone className="w-5 h-5" />
                                    </div>
                                    <div>
                                        <p className="text-sm font-semibold text-gray-500 uppercase tracking-wider mb-1">Support (UK)</p>
                                        <p className="text-[#111827] font-medium">+44 20 7123 4567</p>
                                    </div>
                                </div>

                                <div className="flex items-start gap-4">
                                    <div className="w-10 h-10 rounded-full bg-blue-50 flex items-center justify-center text-[#1A6FF5] flex-shrink-0">
                                        <Mail className="w-5 h-5" />
                                    </div>
                                    <div>
                                        <p className="text-sm font-semibold text-gray-500 uppercase tracking-wider mb-1">Email</p>
                                        <p className="text-[#1A6FF5] font-medium">hello@dialzones.com</p>
                                    </div>
                                </div>
                            </div>
                        </div>

                        {/* Global HQ Card */}
                        {/* Global HQ Card */}
                        <div className="bg-[#0D1B3E] p-8 rounded-3xl shadow-lg text-white">
                            <div className="flex items-center gap-3 mb-6">
                                <MapPin className="w-6 h-6 text-blue-400" />
                                <h3 className="text-xl font-bold">Global Headquarters</h3>
                            </div>
                            <p className="text-blue-200 leading-relaxed mb-6">
                                210 SW Market St<br />
                                Lees Summit, MO 64063-2314<br />
                                United States
                            </p>
                            <div className="flex items-center gap-2 text-sm text-blue-300">
                                <Clock className="w-4 h-4" /> Office Hours: 9 AM - 6 PM (EST)
                            </div>
                        </div>
                    </motion.div>

                    {/* Right Column: Contact Form */}
                    <motion.div
                        initial={{ opacity: 0, x: 30 }}
                        animate={{ opacity: 1, x: 0 }}
                        transition={{ delay: 0.2 }}
                        className="flex-[1.5]"
                    >
                        <div className="bg-white p-8 md:p-12 rounded-3xl border border-gray-200 shadow-xl">
                            <div className="mb-8">
                                <h2 className="text-2xl font-bold text-[#111827] mb-2">Book a tailored demo</h2>
                                <p className="text-gray-500">Fill out the form below and a dialing expert will be in touch within 24 hours.</p>
                            </div>

                            <form className="space-y-6" onSubmit={(e) => e.preventDefault()}>
                                <div className="grid grid-cols-1 md:grid-cols-2 gap-6">
                                    <div className="space-y-2">
                                        <label className="text-sm font-semibold text-gray-700">First Name</label>
                                        <input type="text" className="w-full px-4 py-3 rounded-lg border border-gray-200 focus:ring-2 focus:ring-[#1A6FF5] focus:border-transparent outline-none transition-all" placeholder="John" />
                                    </div>
                                    <div className="space-y-2">
                                        <label className="text-sm font-semibold text-gray-700">Last Name</label>
                                        <input type="text" className="w-full px-4 py-3 rounded-lg border border-gray-200 focus:ring-2 focus:ring-[#1A6FF5] focus:border-transparent outline-none transition-all" placeholder="Doe" />
                                    </div>
                                </div>

                                <div className="grid grid-cols-1 md:grid-cols-2 gap-6">
                                    <div className="space-y-2">
                                        <label className="text-sm font-semibold text-gray-700">Work Email</label>
                                        <input type="email" className="w-full px-4 py-3 rounded-lg border border-gray-200 focus:ring-2 focus:ring-[#1A6FF5] focus:border-transparent outline-none transition-all" placeholder="john@company.com" />
                                    </div>
                                    <div className="space-y-2">
                                        <label className="text-sm font-semibold text-gray-700">Phone Number</label>
                                        <input type="tel" className="w-full px-4 py-3 rounded-lg border border-gray-200 focus:ring-2 focus:ring-[#1A6FF5] focus:border-transparent outline-none transition-all" placeholder="+1 (555) 000-0000" />
                                    </div>
                                </div>

                                <div className="grid grid-cols-1 md:grid-cols-2 gap-6">
                                    <div className="space-y-2">
                                        <label className="text-sm font-semibold text-gray-700">Company Name</label>
                                        <input type="text" className="w-full px-4 py-3 rounded-lg border border-gray-200 focus:ring-2 focus:ring-[#1A6FF5] focus:border-transparent outline-none transition-all" placeholder="Acme Corp" />
                                    </div>
                                    <div className="space-y-2">
                                        <label className="text-sm font-semibold text-gray-700">Number of Agents</label>
                                        <select className="w-full px-4 py-3 rounded-lg border border-gray-200 focus:ring-2 focus:ring-[#1A6FF5] focus:border-transparent outline-none transition-all bg-white">
                                            <option value="">Select team size</option>
                                            <option value="1-10">1-10 agents</option>
                                            <option value="11-50">11-50 agents</option>
                                            <option value="51-200">51-200 agents</option>
                                            <option value="201+">201+ agents</option>
                                        </select>
                                    </div>
                                </div>

                                <div className="space-y-2">
                                    <label className="text-sm font-semibold text-gray-700">How can we help you?</label>
                                    <textarea rows={4} className="w-full px-4 py-3 rounded-lg border border-gray-200 focus:ring-2 focus:ring-[#1A6FF5] focus:border-transparent outline-none transition-all resize-none" placeholder="Tell us about your current dialing setup and goals..."></textarea>
                                </div>

                                <Button className="w-full bg-[#1A6FF5] hover:bg-blue-700 text-white py-6 text-lg font-bold rounded-xl shadow-lg shadow-blue-500/20">
                                    Submit Request
                                </Button>

                                <p className="text-xs text-gray-400 text-center mt-4">
                                    By submitting this form, you agree to our Terms of Service and Privacy Policy.
                                </p>
                            </form>
                        </div>
                    </motion.div>

                </div>
            </section>
        </main>
    )
}