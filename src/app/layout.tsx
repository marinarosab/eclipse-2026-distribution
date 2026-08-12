import type { Metadata } from "next";
import "./globals.css";

export const metadata: Metadata = {
  title: "Eclipse 2026 | Distribuição segura",
  description:
    "Protótipo de produto para gerir a distribuição de óculos de eclipse através de múltiplos pontos de levantamento.",
};

export default function RootLayout({ children }: Readonly<{ children: React.ReactNode }>) {
  return (
    <html lang="pt-PT">
      <body>{children}</body>
    </html>
  );
}
