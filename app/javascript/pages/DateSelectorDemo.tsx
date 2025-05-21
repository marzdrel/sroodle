import { Head } from '@inertiajs/react'
import React, { useState } from 'react'

import Layout from './Layout'

import { DateSelector } from '@/components/DateSelector'
import { Button } from '@/components/ui/button'

export default function DateSelectorDemo() {
  const [selectedDates, setSelectedDates] = useState<Date[]>([])

  const handleDateChange = (dates: Date[]) => {
    setSelectedDates(dates)
  }

  const handleSubmit = (e: React.FormEvent) => {
    e.preventDefault()
    console.warn('Selected dates:', selectedDates)
    // Here you would typically send the data to your backend
  }

  return (
    <Layout>
      <Head title="Date Selection Demo" />
      <div className="max-w-4xl mx-auto">
        <div className="flex justify-between items-center mb-6">
          <div>
            <h1 className="text-2xl font-bold">Event Date Selection</h1>
            <p className="text-sm text-muted-foreground mt-1">
              Select possible dates for your event. Attendees will vote on their preferences.
            </p>
          </div>
        </div>

        <form onSubmit={handleSubmit} className="space-y-6">
          <div className="border rounded-md p-6 bg-card">
            <DateSelector
              onChange={handleDateChange}
              initialDates={[]}
            />
          </div>

          <div className="flex justify-end pt-2">
            <Button
              type="submit"
              size="lg"
              className="px-8"
              disabled={selectedDates.length === 0}
            >
              Save Dates
            </Button>
          </div>
        </form>
      </div>
    </Layout>
  )
}
