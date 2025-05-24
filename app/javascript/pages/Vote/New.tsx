import { Head, useForm } from '@inertiajs/react'
import { CheckCircle2, HelpCircle, XCircle, Send } from 'lucide-react'
import React from 'react'
import { useForm as useReactHookForm } from 'react-hook-form'

import Layout from '../Layout'

import PollDescription from '@/components/PollDescription'
import { Button } from '@/components/ui/button'
import {
  Form,
  FormControl,
  FormDescription,
  FormField,
  FormItem,
  FormLabel,
  FormMessage,
} from '@/components/ui/form'
import { Input } from '@/components/ui/input'

interface PollOption {
  id: number;
  start: string;
  duration_minutes: number;
}

interface Poll {
  id: number;
  name: string;
  description: string;
  options: PollOption[];
}

interface NewProps {
  poll: Poll;
  errors?: string[];
}

interface VoteFormData extends Record<string, string | Record<number, string>> {
  name: string;
  email: string;
  responses: Record<number, string>;
}

export default function New({ poll, errors = [] }: NewProps) {
  const { data, setData, post, processing } = useForm<VoteFormData>({
    name: '',
    email: '',
    responses: {}
  })

  const form = useReactHookForm<VoteFormData>({
    defaultValues: {
      name: '',
      email: '',
      responses: {}
    }
  })

  // Handle case where poll might be undefined
  if (!poll) {
    return (
      <Layout>
        <Head title="Vote - Poll Not Found" />
        <div className="max-w-4xl mx-auto">
          <div className="text-center py-10">
            <h1 className="text-2xl font-bold text-red-600">Poll not found</h1>
            <p className="text-muted-foreground mt-2">The poll you're looking for doesn't exist.</p>
          </div>
        </div>
      </Layout>
    )
  }

  const handleSubmit = (formData: VoteFormData) => {
    setData(formData)
    post(`/polls/${poll.id}/votes`)
  }

  const handleResponseChange = (optionId: number, response: string) => {
    const newResponses = {
      ...data.responses,
      [optionId]: response
    }
    setData({
      ...data,
      responses: newResponses
    })
    form.setValue('responses', newResponses)
  }

  const formatDateTime = (start: string, durationMinutes: number) => {
    const startDate = new Date(start)
    const endDate = new Date(startDate.getTime() + durationMinutes * 60000)

    return {
      date: startDate.toLocaleDateString('en-US', {
        weekday: 'long',
        year: 'numeric',
        month: 'long',
        day: 'numeric'
      }),
      time: `${startDate.toLocaleTimeString('en-US', {
        hour: 'numeric',
        minute: '2-digit'
      })} - ${endDate.toLocaleTimeString('en-US', {
        hour: 'numeric',
        minute: '2-digit'
      })}`
    }
  }

  const getResponseVariant = (response: string) => {
    switch (response) {
      case 'yes': return 'bg-green-100 text-green-800 border-green-200'
      case 'maybe': return 'bg-yellow-100 text-yellow-800 border-yellow-200'
      case 'no': return 'bg-red-100 text-red-800 border-red-200'
      default: return 'bg-gray-100 text-gray-800 border-gray-200'
    }
  }

  return (
    <Layout>
      <Head title={`Vote on ${poll.name}`} />
      <div className="max-w-4xl mx-auto">
        {/* Header */}
        <div className="mb-8">
          <h1 className="text-3xl font-bold">{poll.name}</h1>
          <PollDescription description={poll.description} />
        </div>

        {/* Error Messages */}
        {errors.length > 0 && (
          <div className="mb-6 p-4 bg-red-50 border border-red-200 rounded-lg">
            {errors.map((error, index) => (
              <p key={index} className="text-red-800 text-sm">{error}</p>
            ))}
          </div>
        )}

        <Form {...form}>
          <form onSubmit={form.handleSubmit(handleSubmit)} className="space-y-8">
            {/* Personal Information */}
            <div className="p-6 border rounded-lg bg-card">
              <h2 className="text-lg font-medium mb-4">Your Information</h2>
              <div className="grid grid-cols-1 md:grid-cols-2 gap-4">
                <FormField
                  control={form.control}
                  name="name"
                  render={({ field }) => (
                    <FormItem>
                      <FormLabel>Name</FormLabel>
                      <FormControl>
                        <Input placeholder="Your name" {...field} />
                      </FormControl>
                      <FormDescription>
                        Enter your full name.
                      </FormDescription>
                      <FormMessage />
                    </FormItem>
                  )}
                />

                <FormField
                  control={form.control}
                  name="email"
                  render={({ field }) => (
                    <FormItem>
                      <FormLabel>Email</FormLabel>
                      <FormControl>
                        <Input type="email" placeholder="your.email@example.com" {...field} />
                      </FormControl>
                      <FormDescription>
                        We'll use this to send you poll updates.
                      </FormDescription>
                      <FormMessage />
                    </FormItem>
                  )}
                />
              </div>
            </div>

          {/* Date Options */}
          <div className="p-6 border rounded-lg bg-card">
            <h2 className="text-lg font-medium mb-4">Select Your Availability</h2>
            <div className="space-y-4">
              {poll.options.map((option) => {
                const { date, time } = formatDateTime(option.start, option.duration_minutes)
                const currentResponse = data.responses[option.id] || ''

                return (
                  <div key={option.id} className="p-4 border rounded-lg">
                    <div className="flex flex-col md:flex-row md:items-center md:justify-between gap-4">
                      <div>
                        <h3 className="font-medium">{date}</h3>
                        <p className="text-sm text-muted-foreground">{time}</p>
                      </div>

                      <div className="flex gap-2">
                        {['yes', 'maybe', 'no'].map((response) => {
                          const getIcon = () => {
                            switch (response) {
                              case 'yes': return <CheckCircle2 className="w-4 h-4 text-green-600" />
                              case 'maybe': return <HelpCircle className="w-4 h-4 text-yellow-600" />
                              case 'no': return <XCircle className="w-4 h-4 text-red-600" />
                              default: return null
                            }
                          }

                          const getLabel = () => {
                            switch (response) {
                              case 'yes': return 'Yes'
                              case 'maybe': return 'Maybe'
                              case 'no': return 'No'
                              default: return ''
                            }
                          }

                          return (
                            <button
                              key={response}
                              type="button"
                              onClick={() => handleResponseChange(option.id, response)}
                              className={`px-4 py-2 rounded-md border transition-all flex items-center gap-2 ${
                                currentResponse === response
                                  ? getResponseVariant(response)
                                  : 'bg-gray-50 text-gray-700 border-gray-200 hover:bg-gray-100'
                              }`}
                            >
                              {getIcon()}
                              {getLabel()}
                            </button>
                          )
                        })}
                      </div>
                    </div>
                  </div>
                )
              })}
            </div>
          </div>

          {/* Submit Button */}
          <div className="flex justify-end">
            <Button type="submit" disabled={processing} className="px-8 flex items-center gap-2">
              <Send className="w-4 h-4 text-white" />
              {processing ? 'Submitting...' : 'Submit Vote'}
            </Button>
          </div>
        </form>
        </Form>
      </div>
    </Layout>
  )
}
