// components/layout/Footer.tsx
import Link from 'next/link'
import Image from 'next/image'
import { Mail, Phone, MapPin } from 'lucide-react'

export function Footer() {
  return (
    <footer className="bg-[#0A132B] pt-20 pb-10 border-t border-white/5">
      <div className="container mx-auto px-4 max-w-7xl">
        <div className="grid grid-cols-1 md:grid-cols-2 lg:grid-cols-6 gap-12 mb-16">
          
          {/* Brand & Socials (Spans 2 columns) */}
          <div className="lg:col-span-2">
            <Link href="/" className="flex items-center gap-2 mb-6">
              <div className="bg-white rounded-full p-0.5 flex items-center justify-center">
                <Image src="/logo.jpeg" alt="Dial Zones Logo" width={32} height={32} className="rounded-full object-contain" />
              </div>
              <span className="text-xl font-bold text-white tracking-tight">Dial Zones</span>
            </Link>
            <p className="text-blue-200/70 text-sm mb-8 pr-4 leading-relaxed">
              Connecting Every Call, Everywhere. The enterprise predictive dialing and call center software trusted by global teams to scale their operations securely.
            </p>
            <div className="flex gap-4">
              <Link href="https://www.linkedin.com/in/dialz-zones-57a26b408" target="_blank" rel="noopener noreferrer" className="w-10 h-10 rounded-full bg-white/5 flex items-center justify-center text-white hover:bg-[#1A6FF5] transition-colors" title="LinkedIn">
                <span className="font-bold">in</span>
              </Link>
              <Link href="https://www.facebook.com/share/1B3ZK7gSuf/" target="_blank" rel="noopener noreferrer" className="w-10 h-10 rounded-full bg-white/5 flex items-center justify-center text-white hover:bg-[#1A6FF5] transition-colors" title="Facebook">
                <span className="font-bold">f</span>
              </Link>
              <Link href="https://www.instagram.com/dialzones" target="_blank" rel="noopener noreferrer" className="w-10 h-10 rounded-full bg-white/5 flex items-center justify-center text-white hover:bg-[#1A6FF5] transition-colors" title="Instagram">
                <span className="font-bold">ig</span>
              </Link>
            </div>
          </div>

          {/* Products Column */}
          <div>
            <h4 className="text-white font-bold mb-6">Products</h4>
            <ul className="flex flex-col gap-3 text-sm text-blue-200/70">
              <li><Link href="/products" className="hover:text-white transition-colors">Predictive Dialer</Link></li>
              <li><Link href="/products" className="hover:text-white transition-colors">AI Dialer</Link></li>
              <li><Link href="/products" className="hover:text-white transition-colors">Power Dialer</Link></li>
              <li><Link href="/features" className="hover:text-white transition-colors">Features</Link></li>
            </ul>
          </div>

          {/* Company Column */}
          <div>
            <h4 className="text-white font-bold mb-6">Company</h4>
            <ul className="flex flex-col gap-3 text-sm text-blue-200/70">
              <li><Link href="/about" className="hover:text-white transition-colors">About Us</Link></li>
              <li><Link href="/contact" className="hover:text-white transition-colors">Careers</Link></li>
              <li><Link href="/integrations" className="hover:text-white transition-colors">Partners</Link></li>
              <li><Link href="/blog" className="hover:text-white transition-colors">Blog</Link></li>
            </ul>
          </div>

          {/* Support Column */}
          <div>
            <h4 className="text-white font-bold mb-6">Support</h4>
            <ul className="flex flex-col gap-3 text-sm text-blue-200/70">
              <li><Link href="/contact" className="hover:text-white transition-colors">Contact Us</Link></li>
              <li><Link href="/demo" className="hover:text-white transition-colors">Help Center</Link></li>
              <li><Link href="/integrations" className="hover:text-white transition-colors">API Docs</Link></li>
            </ul>
          </div>

          {/* Single Contact Column */}
          <div>
            <h4 className="text-white font-bold mb-6">Contact</h4>
            <ul className="flex flex-col gap-4 text-sm text-blue-200/70">
              <li className="flex items-start gap-3">
                <MapPin className="w-5 h-5 flex-shrink-0 mt-0.5 text-[#1A6FF5]" />
                <span className="leading-relaxed">210 SW Market St<br/>Lees Summit, MO 64063-2314</span>
              </li>
              <li className="flex items-start gap-3 mt-2">
                <Phone className="w-4 h-4 mt-0.5 text-[#1A6FF5]" />
                +1 (800) 123-4567
              </li>
              <li className="flex items-start gap-3">
                <Mail className="w-4 h-4 text-[#1A6FF5]" />
                hello@dialzones.com
              </li>
            </ul>
          </div>

        </div>

        {/* Bottom Bar with Legal Links */}
        <div className="pt-8 border-t border-white/10 flex flex-col md:flex-row items-center justify-between gap-4 text-xs text-blue-200/50">
          <p>© 2026 Dial Zones Ltd. All rights reserved.</p>
          <div className="flex items-center gap-6">
            <Link href="/privacy" className="hover:text-white transition-colors">Privacy Policy</Link>
            <Link href="/terms" className="hover:text-white transition-colors">Terms of Service</Link>
            <Link href="/security" className="hover:text-white transition-colors">Security</Link>
          </div>
        </div>
      </div>
    </footer>
  )
}