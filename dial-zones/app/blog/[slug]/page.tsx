// app/blog/[slug]/page.tsx
'use client'

import { motion } from 'framer-motion'
import { Calendar, Clock, ArrowLeft, Share2 } from 'lucide-react'
import Link from 'next/link'
import { Button } from '@/components/ui/button'

export default function BlogPost({ params }: { params: { slug: string } }) {
  // Mock content for the single post (In real app, fetch from CMS via slug)
  const post = {
    title: "The Future of Predictive Dialing in 2026",
    category: "Industry Insights",
    author: "Sarah Jenkins",
    authorRole: "CEO, Dial Zones",
    date: "May 12, 2026",
    readTime: "5 min read",
    content: `
      <p>Outbound dialing is undergoing a massive transformation. Gone are the days of simple auto-dialers that annoyed prospects and wasted agent time.</p>
      <h2>The Shift to AI-Driven Pacing</h2>
      <p>Modern predictive dialers now use machine learning to analyze thousands of data points in real-time. They don't just guess when an agent will be free; they calculate the probability based on average talk time, time of day, and lead quality.</p>
      <blockquote>"The goal is zero dead air. When an agent hangs up, the next live prospect should already be on the line."</blockquote>
      <h2>Why Compliance is No Longer Optional</h2>
      <p>With tightening regulations like GDPR and TCPA, manual scrubbing is a liability. Our latest v2.0 engine automates DNC checks at the millisecond level.</p>
    `
  }

  return (
    <main className="min-h-screen bg-white pb-24">
      {/* Post Header & Breadcrumb */}
      <section className="pt-32 pb-12 bg-gray-50">
        <div className="container mx-auto px-4 max-w-4xl">
          <Link href="/blog" className="inline-flex items-center gap-2 text-sm font-semibold text-[#1A6FF5] mb-8 hover:gap-3 transition-all">
            <ArrowLeft className="w-4 h-4" /> Back to Blog
          </Link>

          <div className="flex flex-col items-start gap-4">
            <span className="px-3 py-1 bg-blue-100 text-[#1A6FF5] text-xs font-bold uppercase tracking-wider rounded-full">
              {post.category}
            </span>
            <h1 className="text-4xl md:text-5xl font-heading font-bold text-[#0D1B3E] leading-tight">
              {post.title}
            </h1>

            <div className="flex flex-wrap items-center gap-6 mt-6 pt-6 border-t border-gray-200 w-full">
              <div className="flex items-center gap-3">
                <div className="w-12 h-12 rounded-full bg-[#E8F0FD] flex items-center justify-center text-[#1A6FF5] font-bold">SJ</div>
                <div>
                  <p className="font-bold text-[#111827]">{post.author}</p>
                  <p className="text-xs text-gray-500">{post.authorRole}</p>
                </div>
              </div>
              <div className="flex items-center gap-4 text-sm text-gray-500 ml-auto">
                <span className="flex items-center gap-1.5"><Calendar className="w-4 h-4" /> {post.date}</span>
                <span className="flex items-center gap-1.5"><Clock className="w-4 h-4" /> {post.readTime}</span>
              </div>
            </div>
          </div>
        </div>
      </section>

      {/* Featured Image placeholder per PRD */}
      {/* Featured Image placeholder per PRD */}
      <div className="container mx-auto px-4 max-w-5xl mt-12 mb-16">
        <div className="w-full aspect-video max-h-[400px] bg-[#f8fafc] rounded-[2rem] border border-gray-200 shadow-xl overflow-hidden relative flex items-center justify-center group">
          {/* Subtle Grid Pattern */}
          <div className="absolute inset-0 bg-[linear-gradient(to_right,#1A6FF50a_1px,transparent_1px),linear-gradient(to_bottom,#1A6FF50a_1px,transparent_1px)] bg-[size:24px_24px]"></div>

          <div className="relative z-10 flex flex-col items-center">
            <div className="w-16 h-16 bg-white rounded-full flex items-center justify-center shadow-sm border border-gray-100 mb-4 group-hover:scale-110 transition-transform duration-300">
              <svg className="w-6 h-6 text-gray-400" fill="none" stroke="currentColor" viewBox="0 0 24 24" xmlns="http://www.w3.org/2000/svg"><path strokeLinecap="round" strokeLinejoin="round" strokeWidth={2} d="M4 16l4.586-4.586a2 2 0 012.828 0L16 16m-2-2l1.586-1.586a2 2 0 012.828 0L20 14m-6-6h.01M6 20h12a2 2 0 002-2V6a2 2 0 00-2-2H6a2 2 0 00-2 2v12a2 2 0 002 2z" /></svg>
            </div>
            <span className="text-gray-400 font-semibold text-sm tracking-widest uppercase">High-Resolution Cover Image (16:9)</span>
          </div>
        </div>
      </div>

      {/* Main Content Layout */}
      <section className="container mx-auto px-4 max-w-7xl mt-16">
        <div className="flex flex-col lg:flex-row gap-16">

          {/* Article Body (65%) */}
          <article className="lg:w-2/3 prose prose-lg prose-blue max-w-none">
            <div
              className="text-gray-700 leading-relaxed space-y-6"
              dangerouslySetInnerHTML={{ __html: post.content }}
            />

            {/* Social Share per PRD */}
            <div className="mt-16 pt-8 border-t border-gray-100 flex items-center justify-between">
              <p className="font-bold text-[#111827]">Share this article</p>
              <div className="flex gap-3">
                <button className="w-10 h-10 flex items-center justify-center rounded-full bg-gray-50 text-gray-600 hover:bg-[#1A6FF5] hover:text-white transition-colors font-bold text-sm">X</button>
                <button className="w-10 h-10 flex items-center justify-center rounded-full bg-gray-50 text-gray-600 hover:bg-[#1A6FF5] hover:text-white transition-colors font-bold text-sm">in</button>
                <button className="w-10 h-10 flex items-center justify-center rounded-full bg-gray-50 text-gray-600 hover:bg-[#1A6FF5] hover:text-white transition-colors font-bold text-sm">f</button>
                <button className="w-10 h-10 flex items-center justify-center rounded-full bg-gray-50 text-gray-600 hover:bg-[#1A6FF5] hover:text-white transition-colors">
                  <Share2 className="w-4 h-4" />
                </button>
              </div>
            </div>
          </article>

          {/* Sticky Sidebar (35%) */}
          <aside className="lg:w-1/3">
            <div className="sticky top-32 space-y-8">
              {/* Table of Contents per PRD */}
              <div className="bg-gray-50 p-8 rounded-2xl border border-gray-100">
                <h4 className="font-bold text-[#111827] mb-4 uppercase text-xs tracking-widest">Table of Contents</h4>
                <ul className="space-y-3">
                  <li><Link href="#" className="text-sm text-[#1A6FF5] font-medium hover:underline">Shift to AI-Driven Pacing</Link></li>
                  <li><Link href="#" className="text-sm text-gray-500 hover:text-[#1A6FF5] transition-colors">Why Compliance is Mandatory</Link></li>
                  <li><Link href="#" className="text-sm text-gray-500 hover:text-[#1A6FF5] transition-colors">Future Outlook</Link></li>
                </ul>
              </div>

              {/* Newsletter CTA in Sidebar */}
              <div className="bg-[#0D1B3E] p-8 rounded-2xl text-white shadow-xl">
                <h4 className="text-xl font-bold mb-4">Get the latest insights</h4>
                <p className="text-blue-200 text-sm mb-6">Join 5,000+ call center leaders who get our weekly strategy mail.</p>
                <input type="email" placeholder="Work email" className="w-full px-4 py-3 rounded-lg bg-white/10 border border-white/20 text-white mb-3 outline-none focus:ring-1 focus:ring-blue-400" />
                <Button className="w-full bg-[#1A6FF5] hover:bg-blue-600">Subscribe</Button>
              </div>
            </div>
          </aside>
        </div>
      </section>
    </main>
  )
}