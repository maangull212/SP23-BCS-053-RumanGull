// app/blog/page.tsx
'use client'

import { useState } from 'react'
import { motion } from 'framer-motion'
import { Search, ArrowRight, Clock, Calendar } from 'lucide-react'
import Link from 'next/link'

const categories = ["All", "Guides", "Product News", "Case Studies", "Industry Insights"]

const posts = [
  {
    slug: "future-of-predictive-dialing",
    title: "The Future of Predictive Dialing in 2026",
    excerpt: "How AI and machine learning are pushing connection rates beyond 40% and eliminating dead air completely.",
    category: "Industry Insights",
    author: "Sarah Jenkins",
    authorInitial: "SJ",
    date: "May 12, 2026",
    readTime: "5 min read",
    featured: true
  },
  {
    slug: "dnc-compliance-guide",
    title: "The Ultimate Guide to DNC & TPS Compliance",
    excerpt: "Protect your call center from fines. Learn how automated scrubbing works across global registries.",
    category: "Guides",
    author: "Marcus Rowell",
    authorInitial: "MR",
    date: "May 08, 2026",
    readTime: "8 min read",
    featured: false
  },
  {
    slug: "dial-zones-v2-release",
    title: "Dial Zones v2.0: Introducing Custom Workflows",
    excerpt: "Build complex IVR menus and post-call automation scripts without writing a single line of code.",
    category: "Product News",
    author: "David Chen",
    authorInitial: "DC",
    date: "May 01, 2026",
    readTime: "4 min read",
    featured: false
  },
  {
    slug: "bpo-case-study",
    title: "How Apex BPO Scaled to 500 Agents Smoothly",
    excerpt: "Discover the infrastructure and routing strategies that allowed Apex BPO to double their workforce in 6 months.",
    category: "Case Studies",
    author: "Elena Rodriguez",
    authorInitial: "ER",
    date: "April 24, 2026",
    readTime: "6 min read",
    featured: false
  }
]

export default function BlogListing() {
  const [activeTab, setActiveTab] = useState("All")
  const [searchQuery, setSearchQuery] = useState("")

  const featuredPost = posts.find(p => p.featured)
  const regularPosts = posts.filter(p => !p.featured && (activeTab === "All" || p.category === activeTab) && p.title.toLowerCase().includes(searchQuery.toLowerCase()))

  return (
    <main className="min-h-screen bg-gray-50 pb-24">
      {/* Header */}
      <section className="pt-32 pb-16 bg-[#0D1B3E] text-center text-white">
        <div className="container mx-auto px-4 max-w-4xl">
          <motion.h1 
            initial={{ opacity: 0, y: -20 }}
            animate={{ opacity: 1, y: 0 }}
            className="text-4xl md:text-6xl font-heading font-bold mb-6"
          >
            Insights for call center professionals
          </motion.h1>
          
          <div className="relative max-w-xl mx-auto mt-10">
            <input 
              type="text" 
              placeholder="Search articles..." 
              value={searchQuery}
              onChange={(e) => setSearchQuery(e.target.value)}
              className="w-full pl-12 pr-4 py-4 rounded-xl text-[#111827] outline-none focus:ring-2 focus:ring-[#1A6FF5]"
            />
            <Search className="absolute left-4 top-1/2 -translate-y-1/2 text-gray-400 w-5 h-5" />
          </div>
        </div>
      </section>

      <div className="container mx-auto px-4 max-w-7xl -mt-8 relative z-10">
        
        {/* Featured Post (Only show if search is empty and tab is All) */}
        {featuredPost && activeTab === "All" && !searchQuery && (
          <motion.div 
            initial={{ opacity: 0, y: 20 }}
            animate={{ opacity: 1, y: 0 }}
            className="bg-white rounded-3xl border border-gray-200 shadow-xl overflow-hidden flex flex-col md:flex-row mb-16"
          >
            <div className="md:w-1/2 bg-gradient-to-br from-[#1A6FF5] to-cyan-400 p-12 flex items-center justify-center min-h-[300px]">
               <span className="text-white font-bold text-3xl opacity-50 text-center">Featured Article Visual</span>
            </div>
            <div className="md:w-1/2 p-8 md:p-12 flex flex-col justify-center">
              <span className="inline-block px-3 py-1 bg-blue-50 text-[#1A6FF5] text-xs font-bold uppercase tracking-wider rounded-full mb-4 w-fit">
                {featuredPost.category}
              </span>
              <h2 className="text-3xl font-bold text-[#111827] mb-4 hover:text-[#1A6FF5] transition-colors">
                <Link href={`/blog/${featuredPost.slug}`}>{featuredPost.title}</Link>
              </h2>
              <p className="text-gray-600 text-lg mb-8">{featuredPost.excerpt}</p>
              
              <div className="flex items-center gap-4 mt-auto">
                <div className="w-10 h-10 rounded-full bg-gray-200 flex items-center justify-center text-gray-600 font-bold">
                  {featuredPost.authorInitial}
                </div>
                <div>
                  <p className="font-bold text-[#111827] text-sm">{featuredPost.author}</p>
                  <div className="flex items-center gap-3 text-xs text-gray-500 mt-1">
                    <span className="flex items-center gap-1"><Calendar className="w-3 h-3"/> {featuredPost.date}</span>
                    <span className="flex items-center gap-1"><Clock className="w-3 h-3"/> {featuredPost.readTime}</span>
                  </div>
                </div>
              </div>
            </div>
          </motion.div>
        )}

        {/* Categories */}
        <div className="flex flex-wrap items-center gap-2 mb-10 border-b border-gray-200 pb-4">
          {categories.map(category => (
            <button
              key={category}
              onClick={() => setActiveTab(category)}
              className={`px-5 py-2 rounded-full text-sm font-semibold transition-all ${activeTab === category ? 'bg-[#111827] text-white' : 'bg-transparent text-gray-500 hover:bg-gray-100'}`}
            >
              {category}
            </button>
          ))}
        </div>

        {/* Regular Posts Grid */}
        <div className="grid grid-cols-1 md:grid-cols-2 lg:grid-cols-3 gap-8">
          {regularPosts.map((post, index) => (
            <motion.div 
              key={post.slug}
              initial={{ opacity: 0, y: 20 }}
              whileInView={{ opacity: 1, y: 0 }}
              viewport={{ once: true }}
              transition={{ delay: index * 0.1 }}
              className="bg-white rounded-2xl border border-gray-100 shadow-sm hover:shadow-xl transition-all group flex flex-col"
            >
              <div className="h-48 bg-gray-100 rounded-t-2xl flex items-center justify-center bg-gradient-to-br from-gray-100 to-gray-200">
                <span className="text-gray-400 font-medium">Article Thumbnail</span>
              </div>
              <div className="p-6 flex flex-col flex-grow">
                <span className="text-xs font-bold text-[#1A6FF5] uppercase tracking-wider mb-3">
                  {post.category}
                </span>
                <h3 className="text-xl font-bold text-[#111827] mb-3 group-hover:text-[#1A6FF5] transition-colors line-clamp-2">
                  <Link href={`/blog/${post.slug}`}>{post.title}</Link>
                </h3>
                <p className="text-gray-600 text-sm mb-6 line-clamp-2 flex-grow">{post.excerpt}</p>
                
                <div className="flex items-center justify-between pt-4 border-t border-gray-100">
                  <div className="flex items-center gap-3">
                    <div className="w-8 h-8 rounded-full bg-blue-50 flex items-center justify-center text-[#1A6FF5] font-bold text-xs">
                      {post.authorInitial}
                    </div>
                    <div>
                      <p className="font-bold text-[#111827] text-xs">{post.author}</p>
                      <p className="text-gray-400 text-[10px]">{post.date}</p>
                    </div>
                  </div>
                  <Link href={`/blog/${post.slug}`} className="w-8 h-8 rounded-full bg-gray-50 flex items-center justify-center group-hover:bg-[#1A6FF5] group-hover:text-white transition-colors">
                    <ArrowRight className="w-4 h-4" />
                  </Link>
                </div>
              </div>
            </motion.div>
          ))}
        </div>

        {regularPosts.length === 0 && (
          <div className="text-center py-20 text-gray-500">
            No articles found matching your criteria.
          </div>
        )}

      </div>
    </main>
  )
}