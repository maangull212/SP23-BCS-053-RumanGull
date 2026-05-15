// app/features/page.tsx
'use client'

import { motion } from 'framer-motion'
import { 
  ShieldCheck, Zap, BarChart3, Users, 
  Settings, PhoneCall, Globe2, Lock 
} from 'lucide-react'
import { Button } from '@/components/ui/button'

const features = [
  {
    title: "Intelligent Routing",
    description: "Route calls to the best available agent based on language, skill set, or past interaction history.",
    icon: Users,
    colSpan: "md:col-span-2 lg:col-span-2",
    bgColor: "bg-blue-50"
  },
  {
    title: "Global Numbers",
    description: "Establish local presence in 100+ countries with instant virtual number provisioning.",
    icon: Globe2,
    colSpan: "md:col-span-1 lg:col-span-1",
    bgColor: "bg-indigo-50"
  },
  {
    title: "Real-time Analytics",
    description: "Monitor live agent performance, drop rates, and conversion metrics on a customizable dashboard.",
    icon: BarChart3,
    colSpan: "md:col-span-1 lg:col-span-1",
    bgColor: "bg-emerald-50"
  },
  {
    title: "Call Recording",
    description: "Automatically record, store, and transcribe calls for QA and compliance.",
    icon: PhoneCall,
    colSpan: "md:col-span-2 lg:col-span-1",
    bgColor: "bg-orange-50"
  },
  {
    title: "Custom Workflows",
    description: "Build drag-and-drop IVR menus and post-call automation scripts without writing code.",
    icon: Settings,
    colSpan: "md:col-span-1 lg:col-span-1",
    bgColor: "bg-purple-50"
  },
  {
    title: "Enterprise Security",
    description: "Bank-grade encryption, role-based access control (RBAC), and full audit logs.",
    icon: Lock,
    colSpan: "md:col-span-1 lg:col-span-1",
    bgColor: "bg-slate-50"
  }
]

export default function FeaturesPage() {
  return (
    <main className="min-h-screen bg-white">
      {/* Hero Section */}
      <section className="pt-32 pb-20 bg-[#0D1B3E] text-center text-white relative overflow-hidden">
        {/* Abstract Background Element */}
        <div className="absolute inset-0 z-0 opacity-20 pointer-events-none">
          <div className="absolute top-[-20%] left-[10%] w-[40%] h-[150%] bg-[#1A6FF5] rounded-full blur-[120px]"></div>
        </div>
        
        <div className="container mx-auto px-4 max-w-4xl relative z-10">
          <motion.div
            initial={{ opacity: 0, y: -20 }}
            animate={{ opacity: 1, y: 0 }}
            transition={{ duration: 0.5 }}
          >
            <span className="inline-flex items-center gap-2 px-4 py-1.5 rounded-full bg-white/10 border border-white/20 text-blue-200 text-sm font-semibold mb-6">
              <Zap className="w-4 h-4 text-yellow-400" />
              Over 50+ Enterprise Features
            </span>
            <h1 className="text-4xl md:text-6xl font-heading font-bold mb-6">
              Everything you need to <span className="text-[#1A6FF5]">scale</span> your outbound
            </h1>
            <p className="text-xl text-blue-200 mb-10 max-w-2xl mx-auto">
              From compliance management to advanced AI routing, Dial Zones gives you the tools to optimize every single call.
            </p>
            <Button size="lg" className="bg-[#1A6FF5] hover:bg-blue-600 text-white rounded-full px-8 py-6 text-lg font-bold shadow-lg shadow-blue-500/30 transition-transform hover:scale-105">
              Explore Platform
            </Button>
          </motion.div>
        </div>
      </section>

      {/* Bento Grid Features */}
      <section className="py-24 bg-gray-50">
        <div className="container mx-auto px-4 max-w-7xl">
          <div className="text-center mb-16">
            <h2 className="text-3xl md:text-4xl font-heading font-bold text-[#111827]">
              Powerful capabilities, simple interface
            </h2>
          </div>

          <div className="grid grid-cols-1 md:grid-cols-3 lg:grid-cols-4 gap-6">
            {features.map((feature, index) => (
              <motion.div
                key={index}
                initial={{ opacity: 0, y: 20 }}
                whileInView={{ opacity: 1, y: 0 }}
                viewport={{ once: true, margin: "-50px" }}
                transition={{ delay: index * 0.1, duration: 0.5 }}
                className={`group bg-white p-8 rounded-3xl border border-gray-200 hover:border-[#1A6FF5]/30 hover:shadow-xl hover:-translate-y-1 transition-all duration-300 flex flex-col justify-between overflow-hidden relative ${feature.colSpan}`}
              >
                {/* Decorative background circle */}
                <div className={`absolute -right-8 -top-8 w-32 h-32 rounded-full ${feature.bgColor} opacity-50 group-hover:scale-150 transition-transform duration-700 ease-out`}></div>
                
                <div className="relative z-10">
                  <div className="w-12 h-12 rounded-xl bg-white shadow-sm border border-gray-100 text-[#1A6FF5] flex items-center justify-center mb-6">
                    <feature.icon className="w-6 h-6" />
                  </div>
                  <h3 className="text-xl font-bold text-[#111827] mb-3">{feature.title}</h3>
                  <p className="text-gray-600 leading-relaxed mb-6">{feature.description}</p>
                </div>
              </motion.div>
            ))}
          </div>
        </div>
      </section>

      {/* Security & Compliance Highlight */}
      <section className="py-24 bg-white border-t border-gray-100">
        <div className="container mx-auto px-4 max-w-7xl">
          <div className="flex flex-col md:flex-row items-center gap-16">
            <motion.div 
              initial={{ opacity: 0, x: -50 }}
              whileInView={{ opacity: 1, x: 0 }}
              viewport={{ once: true }}
              className="flex-1"
            >
              <div className="aspect-square max-h-[400px] bg-[#0D1B3E] rounded-[2rem] p-8 relative overflow-hidden flex flex-col items-center justify-center text-center">
                <ShieldCheck className="w-24 h-24 text-blue-400 mb-6" />
                <h3 className="text-2xl font-bold text-white mb-2">Compliance Engine</h3>
                <p className="text-blue-200">Automatic TPS/DNC scrubbing in real-time.</p>
                <div className="absolute inset-0 bg-[linear-gradient(to_right,#4f4f4f2e_1px,transparent_1px),linear-gradient(to_bottom,#4f4f4f2e_1px,transparent_1px)] bg-[size:14px_24px] [mask-image:radial-gradient(ellipse_60%_50%_at_50%_0%,#000_70%,transparent_100%)]"></div>
              </div>
            </motion.div>
            
            <motion.div 
              initial={{ opacity: 0, x: 50 }}
              whileInView={{ opacity: 1, x: 0 }}
              viewport={{ once: true }}
              className="flex-1"
            >
              <h2 className="text-3xl md:text-4xl font-heading font-bold text-[#111827] mb-6">
                Built for the strictest regulatory environments
              </h2>
              <p className="text-lg text-gray-600 mb-8">
                Protect your business from liabilities. Our built-in compliance engine automatically checks every number against global Do-Not-Call registries before a dial is ever initiated.
              </p>
              <ul className="space-y-4">
                {["PCI DSS Level 1 Certified", "GDPR & CCPA Compliant", "Automated call recording redaction"].map((item, i) => (
                  <li key={i} className="flex items-center gap-3 text-[#111827] font-medium">
                    <ShieldCheck className="w-5 h-5 text-green-500" /> {item}
                  </li>
                ))}
              </ul>
            </motion.div>
          </div>
        </div>
      </section>
    </main>
  )
}