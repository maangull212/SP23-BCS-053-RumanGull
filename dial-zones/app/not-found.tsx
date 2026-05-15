// app/not-found.tsx
import Link from 'next/link'
import { Search, ArrowRight } from 'lucide-react'

export default function NotFound() {
  return (
    <main className="min-h-screen bg-gray-50 flex flex-col items-center justify-center pt-20 pb-12 px-4">
      <div className="text-center max-w-2xl mx-auto">
        <h1 className="text-8xl md:text-9xl font-heading font-bold text-[#0D1B3E] mb-4">404</h1>
        <h2 className="text-2xl md:text-3xl font-bold text-[#111827] mb-6">Page not found</h2>
        <p className="text-lg text-gray-600 mb-10">
          The page you are looking for doesn't exist or has been moved. 
        </p>
        
        {/* Search Box per PRD */}
        <div className="relative max-w-md mx-auto mb-12">
          <input 
            type="text" 
            placeholder="Search Dial Zones..." 
            className="w-full pl-12 pr-4 py-4 rounded-xl border border-gray-200 shadow-sm focus:ring-2 focus:ring-[#1A6FF5] focus:border-transparent outline-none"
          />
          <Search className="absolute left-4 top-1/2 -translate-y-1/2 text-gray-400 w-5 h-5" />
        </div>

        <div className="flex flex-col sm:flex-row items-center justify-center gap-4">
          <Link href="/" className="bg-[#1A6FF5] hover:bg-blue-700 text-white px-8 py-4 rounded-xl font-bold transition-all shadow-lg shadow-blue-500/30 flex items-center gap-2">
            Take me home <ArrowRight className="w-5 h-5" />
          </Link>
        </div>

        {/* Suggested Links per PRD */}
        <div className="mt-16 pt-8 border-t border-gray-200">
          <p className="text-sm font-semibold text-gray-500 uppercase tracking-wider mb-4">Suggested Pages</p>
          <div className="flex flex-wrap justify-center gap-6 text-[#1A6FF5] font-medium">
            <Link href="/products" className="hover:underline">Products</Link>
            <Link href="/pricing" className="hover:underline">Pricing</Link>
            <Link href="/contact" className="hover:underline">Contact Support</Link>
          </div>
        </div>
      </div>
    </main>
  )
}