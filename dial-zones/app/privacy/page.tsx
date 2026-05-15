// app/privacy/page.tsx
import Link from 'next/link'
import { ArrowLeft } from 'lucide-react'

export default function PrivacyPolicy() {
  return (
    <main className="min-h-screen bg-gray-50 pt-32 pb-24">
      <div className="container mx-auto px-4 max-w-3xl">
        
        <Link href="/" className="inline-flex items-center gap-2 text-sm font-semibold text-[#1A6FF5] mb-8 hover:gap-3 transition-all">
          <ArrowLeft className="w-4 h-4" /> Back to Home
        </Link>

        <div className="bg-white p-8 md:p-12 rounded-3xl border border-gray-200 shadow-sm">
          <div className="mb-10 pb-10 border-b border-gray-100">
            <h1 className="text-4xl font-heading font-bold text-[#0D1B3E] mb-4">Privacy Policy</h1>
            <p className="text-gray-500">Last updated: May 15, 2026</p>
          </div>

          {/* Prose class automatically styles the typography for readability */}
          <article className="prose prose-blue prose-lg max-w-none text-gray-600">
            <h2>1. Introduction</h2>
            <p>
              At Dial Zones ("we", "our", or "us"), we are committed to protecting your privacy. This Privacy Policy explains how we collect, use, disclose, and safeguard your information when you visit our website or use our enterprise dialing platform.
            </p>

            <h2>2. Information We Collect</h2>
            <p>We collect information that you voluntarily provide to us when you:</p>
            <ul>
              <li>Register for a free trial or enterprise demo.</li>
              <li>Express an interest in obtaining information about us or our products.</li>
              <li>Contact our customer support team.</li>
            </ul>
            <p>
              The personal information that we collect depends on the context of your interactions with us and the platform, the choices you make, and the products and features you use.
            </p>

            <h2>3. How We Use Your Information</h2>
            <p>We use personal information collected via our platform for a variety of business purposes described below:</p>
            <ul>
              <li><strong>To facilitate account creation and logon process:</strong> If you choose to link your account with us to a third-party account (such as your Google or Microsoft account), we use the information you allowed us to collect from those third parties to facilitate account creation.</li>
              <li><strong>To fulfill and manage your orders:</strong> We may use your information to fulfill and manage your subscriptions, payments, and integrations made through the platform.</li>
              <li><strong>To enforce TCPA and GDPR compliance:</strong> We actively monitor usage to ensure all calling activity adheres to global DNC/TPS registries.</li>
            </ul>

            <h2>4. Data Retention</h2>
            <p>
              We will only keep your personal information for as long as it is necessary for the purposes set out in this privacy policy, unless a longer retention period is required or permitted by law (such as tax, accounting, or other legal requirements). Call recordings are retained for a maximum of 90 days unless custom enterprise retention policies are applied.
            </p>

            <h2>5. Contact Us</h2>
            <p>
              If you have questions or comments about this policy, you may email our Data Protection Officer at:
            </p>
            <p className="font-bold text-[#1A6FF5]">
              privacy@dialzones.com
            </p>
          </article>
        </div>
      </div>
    </main>
  )
}