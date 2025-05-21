import { Head, router } from '@inertiajs/react'
import * as React from 'react'
import { useState } from 'react'
import { useForm } from 'react-hook-form'

import Layout from '../Layout'

import { DateSelector } from '@/components/DateSelector'
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
  const [dateErrors, setDateErrors] = useState<string | null>(errors.dates || null);

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

    // Update date errors state
    setDateErrors(errors.dates || null);

    if (errors) {
      Object.entries(errors).forEach(([field, message]) => {
        // Map field name to nested path in form
        const formPath = `poll.${field}` as keyof FormValues;

        // Skip displaying dates error using form error as we show it separately
        if (field !== 'dates') {
          form.setError(formPath, {
            type: 'server',
            message
          });
        }
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

            <FormField
              control={form.control}
              name="poll.dates"
              render={() => (
                <FormItem className="space-y-1">
                  <div className={`mt-8 border rounded-md p-6 bg-card/50 ${dateErrors ? 'border-destructive' : ''}`}>
                    <FormLabel className="text-lg font-medium">Event Dates</FormLabel>
                    <FormDescription className="text-sm text-muted-foreground mt-1">
                      Select possible dates for your event. Attendees will vote on their preferences.
                    </FormDescription>
                    {dateErrors && (
                      <p className="text-sm font-medium text-destructive mt-1 mb-4">{dateErrors}</p>
                    )}
                    {!dateErrors && <div className="mb-4"></div>}
                    <DateSelector
                      onChange={(dates) => {
                        setSelectedDates(dates);
                        // Clear error when user selects at least 2 dates
                        if (dates.length >= 2) {
                          setDateErrors(null);
                        }
                      }}
                      initialDates={[]}
                      hasError={!!dateErrors}
                    />
                  </div>
                  <FormMessage />
                </FormItem>
              )}
            />

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