import type { Metadata } from "next";
import "./globals.css";

export const metadata: Metadata = {
  title: "Nexora | Operations Dashboard",
  description: "Operations automation job dashboard",
};

export default function RootLayout({
  children,
}: Readonly<{
  children: React.ReactNode;
}>) {
  return (
    <html
      lang="en"
      className="h-full"
    >
      <body>{children}</body>
    </html>
  );
}
