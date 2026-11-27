import { Check, Copy, Share2 } from 'lucide-react'
import { useState } from 'react'

import { Button } from '@/components/ui/button'

interface CopyButtonProps {
  value: string;
  label?: string;
  // Use the system share sheet (mobile) when the browser supports it.
  share?: { title: string };
  variant?: 'default' | 'outline' | 'secondary';
}

export default function CopyButton({ value, label = 'Copy link', share, variant = 'outline' }: CopyButtonProps) {
  const [copied, setCopied] = useState(false)

  const handleClick = async () => {
    if (share && typeof navigator.share === 'function') {
      try {
        await navigator.share({ title: share.title, url: value })
        return
      } catch {
        // Cancelled or not allowed: fall back to copying.
      }
    }

    try {
      await navigator.clipboard.writeText(value)
      setCopied(true)
      setTimeout(() => setCopied(false), 2000)
    } catch {
      window.prompt('Copy this link:', value)
    }
  }

  const Icon = copied ? Check : share ? Share2 : Copy

  return (
    <Button type="button" variant={variant} onClick={handleClick} aria-live="polite">
      <Icon className="mr-2 h-4 w-4" />
      {copied ? 'Copied!' : label}
    </Button>
  )
}
