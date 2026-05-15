// components/layout/Navbar.tsx
import Link from 'next/link'
import Image from 'next/image'
import { ChevronDown, PhoneOutgoing, Sparkles, Zap, BarChart3, ShieldCheck, Settings } from 'lucide-react'

export function Navbar() {
  return (
    <nav className="fixed top-0 w-full z-50 bg-[#0D1B3E] py-4 shadow-lg border-b border-white/10">
      <div className="container mx-auto px-4 max-w-7xl flex items-center justify-between">

        {/* Logo */}
        <Link href="/" className="flex items-center gap-2 z-50">
          <div className="bg-white rounded-full p-0.5 flex items-center justify-center">
            <Image src="/logo.jpeg" alt="Dial Zones Logo" width={40} height={40} className="rounded-full object-contain" />
          </div>
          <span className="text-xl font-bold text-white tracking-tight">Dial Zones</span>
        </Link>

        {/* Desktop Links */}
        <div className="hidden md:flex items-center gap-8">

          {/* Products Dropdown */}
          <div className="group relative">
            <Link href="/products" className="flex items-center gap-1 text-sm font-medium text-white/90 hover:text-white transition-colors py-4">
              Products <ChevronDown className="w-4 h-4 opacity-70 group-hover:rotate-180 transition-transform duration-300" />
            </Link>

            {/* Products Mega Menu */}
            <div className="absolute top-full left-1/2 -translate-x-1/2 mt-0 w-[450px] opacity-0 invisible group-hover:opacity-100 group-hover:visible transition-all duration-300 transform translate-y-2 group-hover:translate-y-0 pointer-events-none group-hover:pointer-events-auto z-50">
              <div className="bg-white/95 backdrop-blur-md rounded-2xl shadow-2xl border border-gray-100 p-4 grid grid-cols-2 gap-2 relative overflow-hidden">
                <div className="absolute top-0 left-0 w-full h-1 bg-gradient-to-r from-[#1A6FF5] to-[#06B6D4]"></div>

                <Link href="/products" className="flex items-start gap-3 p-3 rounded-xl hover:bg-gray-50 transition-colors">
                  <div className="bg-blue-100 p-2.5 rounded-lg text-blue-600 mt-0.5"><PhoneOutgoing className="w-5 h-5" /></div>
                  <div>
                    <h4 className="text-sm font-bold text-gray-900">Predictive Dialer</h4>
                    <p className="text-xs text-gray-500 mt-1">High-speed automated dialing</p>
                  </div>
                </Link>

                <Link href="/products" className="flex items-start gap-3 p-3 rounded-xl hover:bg-gray-50 transition-colors">
                  <div className="bg-purple-100 p-2.5 rounded-lg text-purple-600 mt-0.5"><Sparkles className="w-5 h-5" /></div>
                  <div>
                    <h4 className="text-sm font-bold text-gray-900">AI Voicebots</h4>
                    <p className="text-xs text-gray-500 mt-1">Smart lead screening</p>
                  </div>
                </Link>

                <Link href="/products" className="flex items-start gap-3 p-3 rounded-xl hover:bg-gray-50 transition-colors col-span-2">
                  <div className="bg-orange-100 p-2.5 rounded-lg text-orange-600 mt-0.5"><Zap className="w-5 h-5" /></div>
                  <div>
                    <h4 className="text-sm font-bold text-gray-900">Power Dialer</h4>
                    <p className="text-xs text-gray-500 mt-1">Give your agents control without sacrificing speed</p>
                  </div>
                </Link>
              </div>
            </div>
          </div>

          {/* Features Dropdown */}
          <div className="group relative">
            <Link href="/features" className="flex items-center gap-1 text-sm font-medium text-white/90 hover:text-white transition-colors py-4">
              Features <ChevronDown className="w-4 h-4 opacity-70 group-hover:rotate-180 transition-transform duration-300" />
            </Link>

            {/* Features Mega Menu */}
            <div className="absolute top-full left-1/2 -translate-x-1/2 mt-0 w-[450px] opacity-0 invisible group-hover:opacity-100 group-hover:visible transition-all duration-300 transform translate-y-2 group-hover:translate-y-0 pointer-events-none group-hover:pointer-events-auto z-50">
              <div className="bg-white/95 backdrop-blur-md rounded-2xl shadow-2xl border border-gray-100 p-4 grid grid-cols-2 gap-2 relative overflow-hidden">
                <div className="absolute top-0 left-0 w-full h-1 bg-gradient-to-r from-emerald-500 to-teal-400"></div>

                <Link href="/features" className="flex items-start gap-3 p-3 rounded-xl hover:bg-gray-50 transition-colors">
                  <div className="bg-emerald-100 p-2.5 rounded-lg text-emerald-600 mt-0.5"><BarChart3 className="w-5 h-5" /></div>
                  <div>
                    <h4 className="text-sm font-bold text-gray-900">Analytics</h4>
                    <p className="text-xs text-gray-500 mt-1">Real-time agent stats</p>
                  </div>
                </Link>

                <Link href="/features" className="flex items-start gap-3 p-3 rounded-xl hover:bg-gray-50 transition-colors">
                  <div className="bg-red-100 p-2.5 rounded-lg text-red-600 mt-0.5"><ShieldCheck className="w-5 h-5" /></div>
                  <div>
                    <h4 className="text-sm font-bold text-gray-900">Compliance</h4>
                    <p className="text-xs text-gray-500 mt-1">DNC & TPS Scrubbing</p>
                  </div>
                </Link>

                <Link href="/features" className="flex items-start gap-3 p-3 rounded-xl hover:bg-gray-50 transition-colors col-span-2">
                  <div className="bg-slate-100 p-2.5 rounded-lg text-slate-600 mt-0.5"><Settings className="w-5 h-5" /></div>
                  <div>
                    <h4 className="text-sm font-bold text-gray-900">Custom Workflows</h4>
                    <p className="text-xs text-gray-500 mt-1">Build drag-and-drop IVR menus without writing code</p>
                  </div>
                </Link>
              </div>
            </div>
          </div>

          <Link href="/integrations" className="text-sm font-medium text-white/90 hover:text-white transition-colors">Integrations</Link>
          <Link href="/pricing" className="text-sm font-medium text-white/90 hover:text-white transition-colors">Pricing</Link>
          <Link href="/contact" className="text-sm font-medium text-white/90 hover:text-white transition-colors">Company</Link>
          <Link href="/blog" className="text-sm font-medium text-white/90 hover:text-white transition-colors">Blog</Link>
          <Link href="/about" className="text-sm font-medium text-white/90 hover:text-white transition-colors">About</Link>
        </div>

        {/* CTA Buttons */}
        <div className="hidden md:flex items-center gap-4">
          <Link href="/login" className="text-sm font-medium text-white/90 hover:text-white transition-colors">Log In</Link>
          <Link href="/contact" className="bg-[#1A6FF5] hover:bg-blue-600 text-white px-5 py-2.5 rounded-full text-sm font-bold transition-all shadow-lg shadow-blue-500/30">
            Start Free Trial
          </Link>
        </div>
      </div>
    </nav>
  )
}