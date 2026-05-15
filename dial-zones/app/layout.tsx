// app/layout.tsx
import type { Metadata } from "next";
import { Inter, Syne } from "next/font/google";
import "./globals.css";
import { Navbar } from "@/components/layout/Navbar";
import { Footer } from "@/components/layout/Footer"; // <-- IMPORT YAHAN TOP PAR AAYEGA

// Fonts matching PRD
const inter = Inter({ subsets: ["latin"], variable: "--font-dm-sans" });
const syne = Syne({ subsets: ["latin"], variable: "--font-syne" });

export const metadata: Metadata = {
  title: "Dial Zones | Connecting Every Call, Everywhere",
  description: "Enterprise predictive dialing and call center software.",
};

export default function RootLayout({
  children,
}: Readonly<{
  children: React.ReactNode;
}>) {
  return (
    <html lang="en">
      <body className={`${inter.variable} ${syne.variable} font-sans antialiased bg-[#0D1B3E]`}>
        <Navbar />
        {children}
        <Footer /> {/* <-- COMPONENT YAHAN RENDER HOGA */}
      </body>
    </html>
  );
}