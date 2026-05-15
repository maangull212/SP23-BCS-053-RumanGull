// app/integrations/page.tsx
'use client'

import { useState } from 'react'
import { motion, AnimatePresence } from 'framer-motion'
import { Search, Database, Cloud, MessageSquare, Layers, Mail, Zap, ArrowRight } from 'lucide-react'
import { Button } from '@/components/ui/button'

const categories = ["All", "CRM", "Helpdesk", "Email", "Analytics"]

const integrationsData = [
  { name: 'Salesforce', category: 'CRM', icon: Cloud, color: 'text-blue-500', desc: 'Sync leads and log calls automatically.' },
  { name: 'HubSpot', category: 'CRM', icon: Database, color: 'text-orange-500', desc: 'Two-way sync for contacts and call activities.' },
  { name: 'Zendesk', category: 'Helpdesk', icon: MessageSquare, color: 'text-green-600', desc: 'Create tickets directly from the dialer.' },
  { name: 'ActiveCampaign', category: 'Email', icon: Mail, color: 'text-blue-600', desc: 'Trigger email sequences post-call.' },
  { name: 'Zoho CRM', category: 'CRM', icon: Layers, color: 'text-yellow-500', desc: 'Native integration for Zoho ecosystems.' },
  { name: 'Mixpanel', category: 'Analytics', icon: BarChart, color: 'text-purple-500', desc: 'Track call center events and conversions.' },
  { name: 'Pipedrive', category: 'CRM', icon: Database, color: 'text-green-500', desc: 'Move deals across stages based on call outcomes.' },
  { name: 'Intercom', category: 'Helpdesk', icon: MessageSquare, color: 'text-blue-400', desc: 'Manage inbound queries alongside outbound.' },
]

// Simple mock for BarChart since it wasn't in the primary import
function BarChart(props: any) {
  return <svg {...props} xmlns="http://www.w3.org/2000/svg" width="24" height="24" viewBox="0 0 24 24" fill="none" stroke="currentColor" strokeWidth="2" strokeLinecap="round" strokeLinejoin="round"><line x1="18" y1="20" x2="18" y2="10"></line><line x1="12" y1="20" x2="12" y2="4"></line><line x1="6" y1="20" x2="6" y2="14"></line></svg>
}

export default function IntegrationsPage() {
  const [activeTab, setActiveTab] = useState("All")
  const [searchQuery, setSearchQuery] = useState("")

  const filteredIntegrations = integrationsData.filter(int => {
    const matchesTab = activeTab === "All" || int.category === activeTab;
    const matchesSearch = int.name.toLowerCase().includes(searchQuery.toLowerCase());
    return matchesTab && matchesSearch;
  })

  return (
    <main className="min-h-screen bg-gray-50 pb-24">
      {/* Hero Section */}
      <section className="pt-32 pb-20 bg-[#0D1B3E] text-center text-white">
        <div className="container mx-auto px-4 max-w-4xl">
          <motion.h1 
            initial={{ opacity: 0, y: -20 }}
            animate={{ opacity: 1, y: 0 }}
            className="text-4xl md:text-6xl font-heading font-bold mb-6"
          >
            Connect with 40+ tools you already use
          </motion.h1>
          <p className="text-xl text-blue-200 mb-10">
            Seamlessly sync data, trigger workflows, and keep your entire tech stack aligned.
          </p>

          {/* Search Box */}
          <div className="relative max-w-xl mx-auto">
            <input 
              type="text" 
              placeholder="Search integrations..." 
              value={searchQuery}
              onChange={(e) => setSearchQuery(e.target.value)}
              className="w-full pl-12 pr-4 py-4 rounded-xl text-white outline-none focus:ring-2 focus:ring-[#1A6FF5]"
            />
            <Search className="absolute left-4 top-1/2 -translate-y-1/2 text-gray-400 w-5 h-5" />
          </div>
        </div>
      </section>

      <section className="container mx-auto px-4 max-w-7xl -mt-8 relative z-10">
        <div className="bg-white p-4 md:p-8 rounded-3xl border border-gray-200 shadow-sm">
          
          {/* Category Tabs */}
          <div className="flex flex-wrap items-center justify-center gap-2 mb-12">
            {categories.map(category => (
              <button
                key={category}
                onClick={() => setActiveTab(category)}
                className={`px-6 py-2.5 rounded-full text-sm font-semibold transition-all ${activeTab === category ? 'bg-[#1A6FF5] text-white shadow-md' : 'bg-gray-100 text-gray-600 hover:bg-gray-200'}`}
              >
                {category}
              </button>
            ))}
          </div>

          {/* Integrations Grid */}
          <motion.div layout className="grid grid-cols-1 md:grid-cols-2 lg:grid-cols-4 gap-6">
            <AnimatePresence>
              {filteredIntegrations.map((int, index) => (
                <motion.div
                  key={int.name}
                  layout
                  initial={{ opacity: 0, scale: 0.9 }}
                  animate={{ opacity: 1, scale: 1 }}
                  exit={{ opacity: 0, scale: 0.9 }}
                  transition={{ duration: 0.2 }}
                  className="p-6 rounded-2xl border border-gray-100 hover:border-[#1A6FF5]/30 hover:shadow-xl transition-all group cursor-pointer flex flex-col items-start bg-white"
                >
                  <div className="w-12 h-12 rounded-xl bg-gray-50 flex items-center justify-center mb-4 group-hover:scale-110 transition-transform">
                    <int.icon className={`w-6 h-6 ${int.color}`} />
                  </div>
                  <span className="text-xs font-bold uppercase tracking-wider text-gray-400 mb-2">{int.category}</span>
                  <h3 className="text-lg font-bold text-[#111827] mb-2">{int.name}</h3>
                  <p className="text-sm text-gray-500 mb-6 flex-grow">{int.desc}</p>
                  <div className="mt-auto text-sm font-semibold text-[#1A6FF5] flex items-center gap-1 opacity-0 group-hover:opacity-100 transition-opacity">
                    View Integration <ArrowRight className="w-4 h-4" />
                  </div>
                </motion.div>
              ))}
            </AnimatePresence>
          </motion.div>

          {filteredIntegrations.length === 0 && (
            <div className="text-center py-12 text-gray-500">
              No integrations found for "{searchQuery}".
            </div>
          )}

        </div>
      </section>

      {/* API Section */}
      <section className="container mx-auto px-4 max-w-4xl mt-24 text-center">
        <div className="bg-[#0D1B3E] rounded-3xl p-12 text-white relative overflow-hidden">
          <Zap className="absolute top-[-20%] right-[-10%] w-64 h-64 text-blue-500/10" />
          <h2 className="text-3xl font-heading font-bold mb-4 relative z-10">Build custom integrations with our API</h2>
          <p className="text-blue-200 mb-8 relative z-10 max-w-2xl mx-auto">
            Need something specific? Use our robust REST API and webhooks to connect Dial Zones to your proprietary internal tools.
          </p>
          <div className="flex justify-center gap-4 relative z-10">
            <Button className="bg-[#1A6FF5] hover:bg-blue-600 text-white px-8 py-6 rounded-xl">View API Docs</Button>
            <Button variant="outline" className="border-white/20 text-black hover:bg-white/10 px-8 py-6 rounded-xl">Contact Engineering</Button>
          </div>
        </div>
      </section>
    </main>
  )
}