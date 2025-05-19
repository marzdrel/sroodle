import Layout from '../Layout'
import { useForm } from 'react-hook-form'
import { Head, router } from '@inertiajs/react'
import * as React from 'react'
import { useState } from 'react'

import { Button } from '@/components/ui/button'
import { Input } from '@/components/ui/input'
import { DateSelector } from '@/components/DateSelector'

import {
  Form,
  FormControl,
  FormDescription,
  FormField,
  FormItem,
  FormLabel,
  FormMessage,
} from '@/components/ui/form'

interface FormValues {
  poll: {
    name: string;
    email: string;
    event: string;
    description: string;
    dates?: string[];
  };
}

interface NewPollProps {
  poll?: {
    name?: string;
    email?: string;
    event?: string;
    description?: string;
  };
  errors?: Record<string, string>;
}

export default function New({ poll = {}, errors = {} as Record<string, string> }: NewPollProps) {
  const [selectedDates, setSelectedDates] = useState<Date[]>([]);

  const form = useForm<FormValues>({
    defaultValues: {
      poll: {
        name: poll.name || '',
        email: poll.email || '',
        event: poll.event || '',
        description: poll.description || ''
      }
    }
  })

  React.useEffect(() => {
    form.clearErrors();

    if (errors) {
      Object.entries(errors).forEach(([field, message]) => {
        // Map field name to nested path in form
        const formPath = `poll.${field}` as any;
        form.setError(formPath, {
          type: 'server',
          message
        });
      });
    }
  }, [errors, form]);

  function onSubmit(data: FormValues) {
    // Add selected dates to form data
    const formData = {
      ...data,
      poll: {
        ...data.poll,
        dates: selectedDates.map(date => date.toISOString().split('T')[0])
      }
    }
    router.post('/polls', formData)
  }

  return (
    <Layout>
      <Head title="Create New Poll" />
      <div className="max-w-4xl mx-auto">
        <div className="flex justify-between items-center mb-6">
          <div>
            <h1 className="text-2xl font-bold">Create New Poll</h1>
            <p className="text-sm text-muted-foreground mt-1">
              Fill out the form below to create a new poll for your event.
            </p>
          </div>
        </div>

        <Form {...form}>
          <form
            onSubmit={form.handleSubmit(onSubmit)}
            className="space-y-6"
          >
            <FormField
              control={form.control}
              name="poll.name"
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
              name="poll.email"
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

            <FormField
              control={form.control}
              name="poll.event"
              render={({ field }) => (
                <FormItem>
                  <FormLabel>Event</FormLabel>
                  <FormControl>
                    <Input placeholder="Event name" {...field} />
                  </FormControl>
                  <FormDescription>
                    The name of your event.
                  </FormDescription>
                  <FormMessage />
                </FormItem>
              )}
            />

            <FormField
              control={form.control}
              name="poll.description"
              render={({ field }) => (
                <FormItem>
                  <FormLabel>Description</FormLabel>
                  <FormControl>
                    <textarea
                      placeholder="Describe your event..."
                      className="flex min-h-[120px] w-full rounded-md border border-input bg-transparent px-3 py-2 text-sm shadow-sm placeholder:text-muted-foreground focus-visible:outline-none focus-visible:ring-1 focus-visible:ring-ring disabled:cursor-not-allowed disabled:opacity-50"
                      {...field}
                    />
                  </FormControl>
                  <FormDescription>
                    Provide details about your event.
                  </FormDescription>
                  <FormMessage />
                </FormItem>
              )}
            />

            <div className="mt-8 border rounded-md p-6 bg-card/50">
              <h3 className="text-lg font-medium mb-3">Event Dates</h3>
              <p className="text-sm text-muted-foreground mb-4">
                Select possible dates for your event. Attendees will vote on their preferences.
              </p>
              <DateSelector
                onChange={setSelectedDates}
                initialDates={[]}
              />
            </div>

            <div className="flex justify-end pt-6">
              <Button type="submit" size="lg" className="px-8">
                Create Poll
              </Button>
            </div>
          </form>
        </Form>
      </div>
    </Layout>
  )
}