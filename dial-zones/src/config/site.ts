// src/config/site.ts
export const siteConfig = {
  name: "Dial Zones",
  description: "Connecting Every Call, Everywhere. Enterprise predictive dialing and call center software.",
  url: "https://dialzones.com",
  links: {
    twitter: "https://twitter.com/dialzones",
    github: "https://github.com/dialzones", // Ya Facebook/Insta replace karo
    linkedin: "https://linkedin.com/company/dialzones",
    instagram: "https://instagram.com/dialzones",
  },
  contact: {
    supportEmail: "support@dialzones.com",
    salesEmail: "sales@dialzones.com",
    usPhone: "+1 (800) 123-4567",
    ukPhone: "+44 20 7123 4567"
  }
}

export type SiteConfig = typeof siteConfig