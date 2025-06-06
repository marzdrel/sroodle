import { Head, router } from '@inertiajs/react'
import { format } from 'date-fns'
import { Calendar as CalendarIcon } from 'lucide-react'
import * as React from 'react'
import { useState } from 'react'
import { useForm } from 'react-hook-form'

import Layout from '../Layout'

import { DateSelector } from '@/components/DateSelector'
import { Button } from '@/components/ui/button'
import { Calendar } from '@/components/ui/calendar'
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
import {
  Popover,
  PopoverContent,
  PopoverTrigger,
} from '@/components/ui/popover'
import { cn } from '@/lib/utils'

interface FormValues {
  poll: {
    name: string;
    email: string;
    event: string;
    description: string;
    end_voting_at: string;
    dates?: string[];
  };
}

interface NewPollProps {
  poll?: {
    name?: string;
    email?: string;
    event?: string;
    description?: string;
    end_voting_at?: string;
  };
  errors?: Record<string, string>;
  new_poll_path?: string;
  debug?: string;
  user?: {
    email?: string;
  };
}

export default function New({ poll = {}, errors = {} as Record<string, string>, new_poll_path, debug, user }: NewPollProps) {
  const [selectedDates, setSelectedDates] = useState<Date[]>([]);
  const [dateErrors, setDateErrors] = useState<string | null>(errors.dates || null);

  const form = useForm<FormValues>({
    defaultValues: {
      poll: {
        name: poll.name || '',
        email: poll.email || user?.email || '',
        event: poll.event || '',
        description: poll.description || '',
        end_voting_at: poll.end_voting_at || ''
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
    <Layout new_poll_path={new_poll_path} debug={debug} user={user}>
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
                    <Input
                      type="email"
                      placeholder="your.email@example.com"
                      {...field}
                      disabled={!!user?.email}
                    />
                  </FormControl>
                  <FormDescription>
                    {user?.email
                      ? "Using your account email for poll updates."
                      : "We'll use this to send you poll updates."
                    }
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
              name="poll.end_voting_at"
              render={({ field }) => (
                <FormItem className="flex flex-col">
                  <FormLabel>Voting Deadline</FormLabel>
                  <Popover>
                    <PopoverTrigger asChild>
                      <FormControl>
                        <Button
                          variant={"outline"}
                          className={cn(
                            "w-[280px] justify-start text-left font-normal",
                            !field.value && "text-muted-foreground"
                          )}
                        >
                          <CalendarIcon className="mr-2 h-4 w-4" />
                          {field.value ? (
                            format(new Date(field.value), "PPP")
                          ) : (
                            <span>Pick a date</span>
                          )}
                        </Button>
                      </FormControl>
                    </PopoverTrigger>
                    <PopoverContent
                      className="w-auto p-3 bg-white border border-gray-200 shadow-xl z-[100] pointer-events-auto"
                      align="start"
                      side="bottom"
                      sideOffset={5}
                    >
                      <Calendar
                        mode="single"
                        selected={field.value ? new Date(field.value) : undefined}
                        onSelect={(date) => {
                          field.onChange(date ? format(date, "yyyy-MM-dd") : "")
                        }}
                        disabled={(date) =>
                          date < new Date(new Date().setHours(0, 0, 0, 0))
                        }
                        initialFocus
                      />
                    </PopoverContent>
                  </Popover>
                  <FormDescription>
                    Select the date when voting should close (voting will end at 11:59 PM on this date).
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
                      onChange={(dates: Date[]) => {
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
