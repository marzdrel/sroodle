import { Link } from '@inertiajs/react'
import { Menu, X } from "lucide-react"
import React, { useState } from 'react'

import DevelopmentUI from "@/components/DevelopmentUI"
import { Button } from "@/components/ui/button"


interface LayoutProps {
  children: React.ReactNode;
  new_poll_path?: string;
  debug?: string;
  user?: {
    email?: string;
  };
}

export default function Layout({ children, new_poll_path, debug, user }: LayoutProps) {
  console.warn("Layout props:", { children, new_poll_path, debug, user });
  const [isMenuOpen, setIsMenuOpen] = useState(false)

  return (
    <div className="min-h-screen flex flex-col bg-background">
      <DevelopmentUI debug={debug} />
      {/* Navbar */}
      <header className="border-b bg-card text-card-foreground sticky top-0 z-10 w-full">
        <div className="max-w-full px-4 sm:px-6 lg:px-12">
          <div className="flex h-16 items-center justify-between">
            {/* Logo & Brand */}
            <div className="flex items-center">
              <Link href="/" className="flex items-center space-x-2">
                <svg
                  xmlns="http://www.w3.org/2000/svg"
                  viewBox="0 0 24 24"
                  fill="none"
                  stroke="currentColor"
                  strokeWidth="2"
                  strokeLinecap="round"
                  strokeLinejoin="round"
                  className="h-6 w-6 text-primary"
                >
                  <path d="m7.5 4.27 9 5.15" />
                  <path d="M21 8a2 2 0 0 0-1-1.73l-7-4a2 2 0 0 0-2 0l-7 4A2 2 0 0 0 3 8v8a2 2 0 0 0 1 1.73l7 4a2 2 0 0 0 2 0l7-4A2 2 0 0 0 21 16Z" />
                  <path d="m3.3 7 8.7 5 8.7-5" />
                  <path d="M12 22V12" />
                </svg>
                <span className="text-lg font-semibold">Sroodle</span>
              </Link>
            </div>

            {/* Desktop Navigation */}
            <nav className="hidden md:flex items-center space-x-8">
              <Link
                href={new_poll_path}
                className="text-sm font-medium transition-colors hover:text-primary"
              >
                Create Poll
              </Link>
              <Link
                href="/polls"
                className="text-sm font-medium transition-colors hover:text-primary"
              >
                Browse Polls
              </Link>
              <Link
                href="/about"
                className="text-sm font-medium transition-colors hover:text-primary"
              >
                About
              </Link>
            </nav>

            {/* Mobile Menu Button */}
            <div className="flex md:hidden">
              <button
                type="button"
                className="-m-2.5 inline-flex items-center justify-center rounded-md p-2.5 text-gray-700"
                onClick={() => setIsMenuOpen(!isMenuOpen)}
              >
                <span className="sr-only">Open main menu</span>
                {isMenuOpen ? (
                  <X className="h-6 w-6" aria-hidden="true" />
                ) : (
                  <Menu className="h-6 w-6" aria-hidden="true" />
                )}
              </button>
            </div>

            {/* User Email & Auth Buttons */}
            <div className="hidden md:flex items-center space-x-3">
              {user?.email && (
                <span className="text-sm text-muted-foreground mr-2">
                  {user.email}
                </span>
              )}
              <Button variant="outline" size="sm" className="mr-1">
                Sign Up
              </Button>
              <Button size="sm">
                Login
              </Button>
            </div>
          </div>
        </div>

        {/* Mobile Menu */}
        {isMenuOpen && (
          <div className="md:hidden border-t">
            <div className="space-y-1 px-4 py-4">
              <Link
                href={new_poll_path}
                className="block py-2 text-base font-medium transition-colors hover:text-primary"
                onClick={() => setIsMenuOpen(false)}
              >
                Create Poll
              </Link>
              <Link
                href="/polls"
                className="block py-2 text-base font-medium transition-colors hover:text-primary"
                onClick={() => setIsMenuOpen(false)}
              >
                Browse Polls
              </Link>
              <Link
                href="/about"
                className="block py-2 text-base font-medium transition-colors hover:text-primary"
                onClick={() => setIsMenuOpen(false)}
              >
                About
              </Link>
              <div className="pt-4 flex flex-col space-y-2">
                <Button variant="outline" className="w-full">
                  Sign Up
                </Button>
                <Button className="w-full">
                  Login
                </Button>
              </div>
            </div>
          </div>
        )}
      </header>

      {/* Main Content */}
      <main className="flex-grow py-10">
        <div className="max-w-5xl mx-auto px-4 sm:px-6 lg:px-8 w-full">
          <div className="bg-card rounded-lg shadow p-4 sm:p-8 min-h-[400px]">
            {children}
          </div>
        </div>
      </main>

      {/* Footer */}
      <footer className="bg-card border-t py-6">
        <div className="max-w-6xl mx-auto px-4 sm:px-6 lg:px-8">
          <div className="flex flex-col items-center justify-between md:flex-row">
            <div className="flex items-center space-x-2">
              <svg
                xmlns="http://www.w3.org/2000/svg"
                viewBox="0 0 24 24"
                fill="none"
                stroke="currentColor"
                strokeWidth="2"
                strokeLinecap="round"
                strokeLinejoin="round"
                className="h-5 w-5 text-primary"
              >
                <path d="m7.5 4.27 9 5.15" />
                <path d="M21 8a2 2 0 0 0-1-1.73l-7-4a2 2 0 0 0-2 0l-7 4A2 2 0 0 0 3 8v8a2 2 0 0 0 1 1.73l7 4a2 2 0 0 0 2 0l7-4A2 2 0 0 0 21 16Z" />
                <path d="m3.3 7 8.7 5 8.7-5" />
                <path d="M12 22V12" />
              </svg>
              <span className="text-sm font-medium">Sroodle</span>
            </div>
            <p className="mt-4 text-center text-xs text-muted-foreground md:mt-0">
              &copy; {new Date().getFullYear()} Sroodle. All rights reserved.
            </p>
          </div>
        </div>
      </footer>
    </div>
  )
}
