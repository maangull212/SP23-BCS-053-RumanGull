// app/products/page.tsx
'use client'

import { motion } from 'framer-motion'
import { 
  PhoneOutgoing, Sparkles, Zap, PhoneForwarded, 
  Voicemail, Server, CheckCircle2, ArrowRight 
} from 'lucide-react'
import { Button } from '@/components/ui/button'

const productDetails = [
  {
    title: "Predictive Dialer",
    tagline: "The Engine of Efficiency",
    description: "Our world-class algorithm minimizes agent wait time by predicting exactly when the next live prospect will answer. Perfect for large-scale outbound teams.",
    features: ["Advanced Answering Machine Detection", "Real-time Pacing Adjustment", "CRM Integration Included"],
    icon: PhoneOutgoing,
    color: "bg-blue-600"
  },
  {
    title: "AI Dialer / Voicebots",
    tagline: "24/7 Prospecting",
    description: "Let AI handle the initial screening. Our smart voicebots qualify leads before handing them over to your top closers.",
    features: ["Natural Language Processing", "Instant Lead Qualification", "Multi-language Support"],
    icon: Sparkles,
    color: "bg-cyan-500"
  },
  {
    title: "Power Dialer",
    tagline: "Agent-Controlled Speed",
    description: "Give your agents control without sacrificing speed. One-click dialing that ensures 100% of calls are managed by a human representative.",
    features: ["No-delay call connection", "Personalized caller ID", "Automated call logging"],
    icon: Zap,
    color: "bg-orange-500"
  }
]

export default function ProductsPage() {
  return (
    <main className="min-h-screen bg-white">
      {/* Header Section */}
      <section className="pt-32 pb-20 bg-[#0D1B3E] text-center text-white">
        <div className="container mx-auto px-4 max-w-7xl">
          <motion.h1 
            initial={{ opacity: 0, y: -20 }}
            animate={{ opacity: 1, y: 0 }}
            className="text-4xl md:text-6xl font-heading font-bold mb-6"
          >
            Communication <span className="text-[#1A6FF5]">Engineered</span>
          </motion.h1>
          <p className="text-xl text-blue-200 max-w-3xl mx-auto">
            From predictive algorithms to AI voicebots, discover the tools that power the world's most productive call centers.
          </p>
        </div>
      </section>

      {/* Deep Dive Section */}
      <section className="py-24">
        <div className="container mx-auto px-4 max-w-7xl">
          <div className="flex flex-col gap-32">
            {productDetails.map((product, index) => (
              <div 
                key={index} 
                className={`flex flex-col lg:flex-row items-center gap-16 ${index % 2 !== 0 ? 'lg:flex-row-reverse' : ''}`}
              >
                {/* Visual Placeholder */}
                <motion.div 
                  initial={{ opacity: 0, scale: 0.9 }}
                  whileInView={{ opacity: 1, scale: 1 }}
                  viewport={{ once: true }}
                  className="flex-1 w-full aspect-video bg-gray-50 rounded-3xl border border-gray-100 shadow-2xl flex items-center justify-center relative overflow-hidden"
                >
                  <div className={`absolute top-0 left-0 w-full h-2 ${product.color}`}></div>
                  <product.icon className={`w-24 h-24 ${product.color.replace('bg-', 'text-')} opacity-20`} />
                  <span className="text-gray-400 font-medium tracking-widest uppercase text-sm">Product Interface Mockup</span>
                </motion.div>

                {/* Content */}
                <motion.div 
                  initial={{ opacity: 0, x: index % 2 === 0 ? 50 : -50 }}
                  whileInView={{ opacity: 1, x: 0 }}
                  viewport={{ once: true }}
                  className="flex-1"
                >
                  <span className="text-[#1A6FF5] font-bold tracking-widest uppercase text-sm">{product.tagline}</span>
                  <h2 className="text-4xl font-heading font-bold text-[#111827] mt-4 mb-6">{product.title}</h2>
                  <p className="text-lg text-gray-600 mb-8 leading-relaxed">{product.description}</p>
                  
                  <ul className="space-y-4 mb-10">
                    {product.features.map((feat, i) => (
                      <li key={i} className="flex items-center gap-3 text-[#111827] font-medium">
                        <CheckCircle2 className="w-5 h-5 text-green-500" /> {feat}
                      </li>
                    ))}
                  </ul>

                  <div className="flex gap-4">
                    <Button className="bg-[#1A6FF5] hover:bg-blue-700 text-white px-8 py-6 rounded-xl">Get Started</Button>
                    <Button variant="ghost" className="text-[#111827] font-bold">Documentation <ArrowRight className="ml-2 w-4 h-4" /></Button>
                  </div>
                </motion.div>
              </div>
            ))}
          </div>
        </div>
      </section>

      {/* Comparison CTA */}
      <section className="py-20 bg-gray-50 border-t border-gray-100">
        <div className="container mx-auto px-4 max-w-4xl text-center">
          <h3 className="text-2xl md:text-3xl font-bold text-[#111827] mb-6">Not sure which dialer is right for you?</h3>
          <p className="text-gray-600 mb-8">Compare all features across our entire product suite to find your perfect fit.</p>
          <Button size="lg" variant="outline" className="border-2 border-[#1A6FF5] text-[#1A6FF5] hover:bg-[#1A6FF5] hover:text-white px-10 py-7 text-lg rounded-2xl">
            Compare Features Side-by-Side
          </Button>
        </div>
      </section>
    </main>
  )
}