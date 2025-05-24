import React from 'react'

interface PollDescriptionProps {
  description?: string | null;
}

export default function PollDescription({ description }: PollDescriptionProps) {
  return (
    <div className="mt-6 p-4 bg-muted/50 rounded-lg">
      <h2 className="text-lg font-medium mb-2">Description</h2>
      <p className="text-sm text-muted-foreground">
        {description || <em>No description provided</em>}
      </p>
    </div>
  )
}